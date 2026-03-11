import { Component, OnInit } from '@angular/core';
import {
  KomentariService,
  KomentarPredstava,
  PagedResult as PagedKomentarResult,
} from '../../services/komentari.service';
import { Predstava } from '../../models/models';
import { PredstaveService } from '../../services/predstava.service ';
import { ChangeDetectorRef } from '@angular/core';
@Component({
  selector: 'app-komentari-predstave-screen',
  templateUrl: './komentari-predstave-screen.html',
  styleUrls: ['./komentari-predstave-screen.css'],
  standalone: false

})
export class KomentariPredstaveScreen implements OnInit {

  // PREDSTAVE
  allPredstave: Predstava[] = [];
  displayedPredstave: Predstava[] = [];

  currentPagePredstave = 1;
  totalPagesPredstave = 1;
  pageSizePredstave = 5;

  searchNaziv = '';

  isLoadingPredstave = false;
  errorPredstave: string | null = null;

  // KOMENTARI
  expandedIds: Set<number> = new Set();

  komentariMap: { [predstavaId: number]: PagedKomentarResult<KomentarPredstava> } = {};
  komentariPageMap: { [predstavaId: number]: number } = {};
  komentariLoading: { [predstavaId: number]: boolean } = {};

  pageSizeKomentari = 3;

constructor(
  private predstaveService: PredstaveService,
  private komentariService: KomentariService,
  private cd: ChangeDetectorRef
) {}

  ngOnInit(): void {
    this.loadPredstave();
  }

  // ---------------- PREDSTAVE ----------------

  loadPredstave(): void {
    this.isLoadingPredstave = true;
    this.errorPredstave = null;

    this.predstaveService.getPredstaveLov().subscribe({
      next: (res) => {
        this.allPredstave = res?.resultList || [];
        this.currentPagePredstave = 1;
        this.applyPredstaveFiltersAndPaging();
        this.isLoadingPredstave = false;

        this.cd.detectChanges();  // 🔴 FORCE UI REFRESH
      },
      error: (err) => {
        this.errorPredstave = `Greška pri dohvaćanju podataka: ${err?.message || err}`;
        this.isLoadingPredstave = false;

        this.cd.detectChanges();  // 🔴 FORCE UI REFRESH
      }
    });
  }

  private applyPredstaveFiltersAndPaging(): void {

    let filtered = [...this.allPredstave];

    if (this.searchNaziv?.trim()) {
      const term = this.searchNaziv.trim().toLowerCase();

      filtered = filtered.filter(p =>
        (p.naziv || '').toLowerCase().includes(term)
      );
    }

    const total = filtered.length;

    this.totalPagesPredstave = Math.max(
      1,
      Math.ceil(total / this.pageSizePredstave)
    );

    if (this.currentPagePredstave > this.totalPagesPredstave) {
      this.currentPagePredstave = this.totalPagesPredstave;
    }

    const startIndex =
      (this.currentPagePredstave - 1) * this.pageSizePredstave;

    const endIndex = startIndex + this.pageSizePredstave;

    this.displayedPredstave = filtered.slice(startIndex, endIndex);
  }

  onSearchChange(value: string): void {
    this.searchNaziv = value;
    this.currentPagePredstave = 1;
    this.applyPredstaveFiltersAndPaging();
  }

  prevPagePredstave(): void {
    if (this.currentPagePredstave > 1) {
      this.currentPagePredstave--;
      this.applyPredstaveFiltersAndPaging();
    }
  }

  nextPagePredstave(): void {
    if (this.currentPagePredstave < this.totalPagesPredstave) {
      this.currentPagePredstave++;
      this.applyPredstaveFiltersAndPaging();
    }
  }

  // ---------------- KOMENTARI ----------------

  isExpanded(predstavaId: number): boolean {
    return this.expandedIds.has(predstavaId);
  }

  toggleExpand(predstavaId: number): void {

    if (this.expandedIds.has(predstavaId)) {
      this.expandedIds.delete(predstavaId);
      return;
    }

    this.expandedIds.add(predstavaId);
    this.komentariPageMap[predstavaId] = 1;

    if (!this.komentariMap[predstavaId]) {
      this.loadKomentari(predstavaId, 1);
    }
  }

 loadKomentari(predstavaId: number, page: number): void {

  this.komentariLoading[predstavaId] = true;

  this.komentariService
    .getKomentari(predstavaId, page, this.pageSizeKomentari)
    .subscribe({
      next: (res) => {

        this.komentariMap[predstavaId] = res || {
          resultList: [],
          count: 0
        };

        this.komentariPageMap[predstavaId] = page;
        this.komentariLoading[predstavaId] = false;

        this.cd.detectChanges();   // 🔴 OVO FALI
      },
      error: () => {

        this.komentariMap[predstavaId] = {
          resultList: [],
          count: 0
        };

        this.komentariPageMap[predstavaId] = page;
        this.komentariLoading[predstavaId] = false;

        this.cd.detectChanges();   // 🔴 I OVDJE
      }
    });
}
  getTotalKomentariPages(predstavaId: number): number {

    const count = this.komentariMap[predstavaId]?.count || 0;

    return Math.max(
      1,
      Math.ceil(count / this.pageSizeKomentari)
    );
  }

  prevPage(predstavaId: number): void {

    const current = this.komentariPageMap[predstavaId] || 1;

    if (current > 1) {
      this.loadKomentari(predstavaId, current - 1);
    }
  }

  nextPage(predstavaId: number): void {

    const current = this.komentariPageMap[predstavaId] || 1;
    const total = this.getTotalKomentariPages(predstavaId);

    if (current < total) {
      this.loadKomentari(predstavaId, current + 1);
    }
  }

  // DELETE MODAL
  showDeleteModal = false;
  pendingDeletePredstavaId: number | null = null;
  pendingDeleteKomentarId: number | null = null;
  isDeleting = false;

  openDeleteModal(predstavaId: number, komentarId: number): void {
    this.pendingDeletePredstavaId = predstavaId;
    this.pendingDeleteKomentarId = komentarId;
    this.showDeleteModal = true;
    this.cd.detectChanges();
  }

  cancelDelete(): void {
    this.showDeleteModal = false;
    this.pendingDeletePredstavaId = null;
    this.pendingDeleteKomentarId = null;
    this.cd.detectChanges();
  }

  confirmDelete(): void {
    if (this.pendingDeleteKomentarId == null || this.pendingDeletePredstavaId == null) return;

    this.isDeleting = true;
    const predstavaId = this.pendingDeletePredstavaId;
    const komentarId = this.pendingDeleteKomentarId;

    this.komentariService.deleteKomentar(komentarId).subscribe({
      next: () => {
        this.isDeleting = false;
        this.showDeleteModal = false;
        this.pendingDeletePredstavaId = null;
        this.pendingDeleteKomentarId = null;
        const currentPage = this.komentariPageMap[predstavaId] || 1;
        this.loadKomentari(predstavaId, currentPage);
        this.cd.detectChanges();
      },
      error: (err) => {
        this.isDeleting = false;
        this.showDeleteModal = false;
        this.cd.detectChanges();
        window.alert(`Greška: ${err?.message || err}`);
      }
    });
  }

  deleteKomentar(predstavaId: number, komentarId: number): void {
    this.openDeleteModal(predstavaId, komentarId);
  }

  // ── OCJENA helpers ──
  getStars(ocjena: number | undefined): boolean[] {
    const max = 5;
    const val = Math.round(ocjena ?? 0);
    return Array.from({ length: max }, (_, i) => i < val);
  }

}
