import { Component, OnInit } from '@angular/core';
import {
  NovostiService,
  Novost,
  KomentarObavijest,
  OdgovorKomentar,
  PagedResult,
} from '../../services/novosti.service';
import { ChangeDetectorRef } from '@angular/core';

@Component({
  selector: 'app-komentari-novosti-screen',
  templateUrl: './komentari-novosti-screen.html',
  styleUrls: ['./komentari-novosti-screen.css'],
  standalone: false,
})
export class KomentariNovostiScreen implements OnInit {
  // Novosti (obavijesti) listing + search/pagination
  obavijesti: Novost[] = [];
  currentPage = 1;
  totalCount = 0;
  pageSize = 6;
  searchNaslov = '';
  isLoadingNovosti = false;
  errorNovosti: string | null = null;

  // Expanded cards state (which news' comments are visible)
  expandedObavijestId: number | null = null;

  // Komentari per obavijest
  komentariMap: { [obavijestId: number]: PagedResult<KomentarObavijest> } = {};
  komentariPageMap: { [obavijestId: number]: number } = {};
  komentariLoading: { [obavijestId: number]: boolean } = {};
  komentariPageSize = 2;

  // Odgovori na komentare
  expandedOdgovoriIds: Set<number> = new Set();
  odgovoriMap: { [komentarId: number]: PagedResult<OdgovorKomentar> } = {};
  odgovoriPageMap: { [komentarId: number]: number } = {};
  odgovoriLoading: { [komentarId: number]: boolean } = {};
  odgovoriPageSize = 5;

constructor(
  private novostiService: NovostiService,
  private cd: ChangeDetectorRef
) {}


  ngOnInit(): void {
    this.loadNovosti();
  }
loadNovosti(): void {
  this.isLoadingNovosti = true;
  this.errorNovosti = null;

  this.novostiService
    .getNovosti({
      page: this.currentPage,
      pageSize: this.pageSize,
      naslov: this.searchNaslov || undefined,
      datumObjave: null,
    })
    .subscribe({
      next: (res) => {
        this.obavijesti = res.data || [];
        this.totalCount = res.count || 0;
        this.isLoadingNovosti = false;

        // Force UI refresh odmah nakon učitavanja
        this.cd.detectChanges();
      },
      error: (err) => {
        this.errorNovosti = `Greška pri dohvaćanju obavijesti: ${
          err?.message || err
        }`;
        this.obavijesti = [];
        this.totalCount = 0;
        this.isLoadingNovosti = false;

        // Force UI refresh i kod greške
        this.cd.detectChanges();
      },
    });
}

  get totalPages(): number {
    return Math.max(1, Math.ceil(this.totalCount / this.pageSize));
  }

  onSearchChange(value: string): void {
    this.searchNaslov = value;
    this.currentPage = 1;
    this.loadNovosti();
  }

  goToPage(page: number): void {
    if (page < 1 || page > this.totalPages) {
      return;
    }
    this.currentPage = page;
    this.loadNovosti();
  }

  // ---------- Komentari (comments) ----------

  isExpanded(obavijestId: number): boolean {
    return this.expandedObavijestId === obavijestId;
  }

  toggleExpand(obavijestId: number): void {
    if (this.expandedObavijestId === obavijestId) {
      this.expandedObavijestId = null;
      return;
    }

    this.expandedObavijestId = obavijestId;

    if (!this.komentariPageMap[obavijestId]) {
      this.komentariPageMap[obavijestId] = 1;
    }

    const page = this.komentariPageMap[obavijestId];
    this.loadKomentari(obavijestId, page);
  }

  loadKomentari(obavijestId: number, page: number): void {
  this.komentariLoading[obavijestId] = true;

  this.novostiService
    .getKomentariByObavijest(obavijestId, page, this.komentariPageSize)
    .subscribe({
      next: (res) => {
        this.komentariMap[obavijestId] = res || { resultList: [], count: 0 };
        this.komentariPageMap[obavijestId] = page;
        this.komentariLoading[obavijestId] = false;

        // 🔴 FORCE UI refresh odmah
        this.cd.detectChanges();
      },
      error: () => {
        this.komentariMap[obavijestId] = { resultList: [], count: 0 };
        this.komentariPageMap[obavijestId] = page;
        this.komentariLoading[obavijestId] = false;

        // 🔴 FORCE UI refresh i kod greške
        this.cd.detectChanges();
      },
    });
}


  getTotalKomentariPages(obavijestId: number): number {
    const count = this.komentariMap[obavijestId]?.count || 0;
    return Math.max(1, Math.ceil(count / this.komentariPageSize));
  }

  prevKomentariPage(obavijestId: number): void {
    const current = this.komentariPageMap[obavijestId] || 1;
    if (current > 1) {
      this.loadKomentari(obavijestId, current - 1);
    }
  }

  nextKomentariPage(obavijestId: number): void {
    const current = this.komentariPageMap[obavijestId] || 1;
    const total = this.getTotalKomentariPages(obavijestId);
    if (current < total) {
      this.loadKomentari(obavijestId, current + 1);
    }
  }

  // ── DELETE MODAL ──
  showDeleteModal = false;
  deleteType: 'komentar' | 'odgovor' = 'komentar';
  isDeleting = false;

  private _pendingObavijestId: number | null = null;
  private _pendingKomentarId: number | null = null;
  private _pendingOdgovorId: number | null = null;

  openDeleteKomentarModal(obavijestId: number, komentarId: number): void {
    this._pendingObavijestId = obavijestId;
    this._pendingKomentarId = komentarId;
    this._pendingOdgovorId = null;
    this.deleteType = 'komentar';
    this.showDeleteModal = true;
    this.cd.detectChanges();
  }

  openDeleteOdgovorModal(komentarId: number, odgovorId: number): void {
    this._pendingKomentarId = komentarId;
    this._pendingOdgovorId = odgovorId;
    this._pendingObavijestId = null;
    this.deleteType = 'odgovor';
    this.showDeleteModal = true;
    this.cd.detectChanges();
  }

  cancelDelete(): void {
    this.showDeleteModal = false;
    this._pendingObavijestId = null;
    this._pendingKomentarId = null;
    this._pendingOdgovorId = null;
    this.cd.detectChanges();
  }

  confirmDelete(): void {
    if (this.deleteType === 'komentar') {
      this._doDeleteKomentar();
    } else {
      this._doDeleteOdgovor();
    }
  }

  private _doDeleteKomentar(): void {
    if (this._pendingKomentarId == null || this._pendingObavijestId == null) return;
    const obavijestId = this._pendingObavijestId;
    const komentarId = this._pendingKomentarId;

    this.isDeleting = true;
    this.novostiService.deleteKomentarObavijest(komentarId).subscribe({
      next: () => {
        this.isDeleting = false;
        this.showDeleteModal = false;
        const currentPage = this.komentariPageMap[obavijestId] || 1;
        this.loadKomentari(obavijestId, currentPage);
        this.expandedOdgovoriIds.delete(komentarId);
        this.cd.detectChanges();
      },
      error: (err) => {
        this.isDeleting = false;
        this.showDeleteModal = false;
        this.cd.detectChanges();
        window.alert(`Greška pri brisanju komentara: ${err?.message || err}`);
      },
    });
  }

  deleteKomentar(obavijestId: number, komentarId: number): void {
    this.openDeleteKomentarModal(obavijestId, komentarId);
  }

  // ---------------- ODGOVORI NA KOMENTARE ----------------

  isOdgovoriExpanded(komentarId: number): boolean {
    return this.expandedOdgovoriIds.has(komentarId);
  }

  toggleOdgovori(komentarId: number, brojOdgovora: number): void {
    if (this.expandedOdgovoriIds.has(komentarId)) {
      this.expandedOdgovoriIds.delete(komentarId);
      this.cd.detectChanges();
      return;
    }

    if (brojOdgovora <= 0) return;

    this.expandedOdgovoriIds.add(komentarId);

    if (!this.odgovoriPageMap[komentarId]) {
      this.odgovoriPageMap[komentarId] = 1;
    }

    this.loadOdgovori(komentarId, this.odgovoriPageMap[komentarId]);
  }

  loadOdgovori(komentarId: number, page: number): void {
    this.odgovoriLoading[komentarId] = true;
    this.cd.detectChanges();

    this.novostiService
      .getOdgovoriByKomentar(komentarId, page, this.odgovoriPageSize)
      .subscribe({
        next: (res) => {
          this.odgovoriMap[komentarId] = res || { resultList: [], count: 0 };
          this.odgovoriPageMap[komentarId] = page;
          this.odgovoriLoading[komentarId] = false;
          this.cd.detectChanges();
        },
        error: () => {
          this.odgovoriMap[komentarId] = { resultList: [], count: 0 };
          this.odgovoriPageMap[komentarId] = page;
          this.odgovoriLoading[komentarId] = false;
          this.cd.detectChanges();
        },
      });
  }

  getTotalOdgovoriPages(komentarId: number): number {
    const count = this.odgovoriMap[komentarId]?.count || 0;
    return Math.max(1, Math.ceil(count / this.odgovoriPageSize));
  }

  prevOdgovoriPage(komentarId: number): void {
    const current = this.odgovoriPageMap[komentarId] || 1;
    if (current > 1) {
      this.loadOdgovori(komentarId, current - 1);
    }
  }

  nextOdgovoriPage(komentarId: number): void {
    const current = this.odgovoriPageMap[komentarId] || 1;
    const total = this.getTotalOdgovoriPages(komentarId);
    if (current < total) {
      this.loadOdgovori(komentarId, current + 1);
    }
  }

  private _doDeleteOdgovor(): void {
    if (this._pendingKomentarId == null || this._pendingOdgovorId == null) return;
    const komentarId = this._pendingKomentarId;
    const odgovorId = this._pendingOdgovorId;

    this.isDeleting = true;
    this.novostiService.deleteOdgovorKomentar(odgovorId).subscribe({
      next: () => {
        this.isDeleting = false;
        this.showDeleteModal = false;
        const currentPage = this.odgovoriPageMap[komentarId] || 1;
        this.loadOdgovori(komentarId, currentPage);
        this.cd.detectChanges();
      },
      error: (err) => {
        this.isDeleting = false;
        this.showDeleteModal = false;
        this.cd.detectChanges();
        window.alert(`Greška pri brisanju odgovora: ${err?.message || err}`);
      },
    });
  }

  deleteOdgovor(komentarId: number, odgovorId: number): void {
    this.openDeleteOdgovorModal(komentarId, odgovorId);
  }

}
