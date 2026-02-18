import { Component, OnInit } from '@angular/core';
import { KomentariService, KomentarPredstava } from '../../services/komentari.service';
import { Predstava } from '../../models/models';
import { PredstaveService } from '../../services/predstava.service ';
interface PagedResult<T> {
  resultList: T[];
  count: number;
}

interface KomentarPredstavaDTO {
  id: number;
  imeKorisnika: string;
  prezimeKorisnika: string;
  komentar: string;
  datum: string;
}
@Component({
  selector: 'app-komentari-predstave-screen',
  templateUrl: './komentari-predstave-screen.html',
  styleUrls: ['./komentari-predstave-screen.css'],
  standalone: false

})
export class KomentariPredstaveScreen implements OnInit {

  predstave: Predstava[] = [];
  expandedIds: Set<number> = new Set();

  komentariMap: { [predstavaId: number]: PagedResult<KomentarPredstava> } = {};
  komentariPageMap: { [predstavaId: number]: number } = {};

  pageSizeKomentari: number = 4;

  constructor(
    private predstaveService: PredstaveService,
    private komentariService: KomentariService
  ) {}

    public getTotalKomentariPages(predstavaId: number): number {
    const count = this.komentariMap[predstavaId]?.count || 0;
    return Math.ceil(count / this.pageSizeKomentari);
  }

  ngOnInit() {
    this.loadPredstave();
  }

  loadPredstave() {
    this.predstaveService.getPredstaveLov().subscribe(res => {
      this.predstave = res.resultList || [];
    });
  }

  toggleExpand(predstavaId: number) {
    if (this.expandedIds.has(predstavaId)) {
      this.expandedIds.delete(predstavaId);
    } else {
      this.expandedIds.add(predstavaId);
      this.komentariPageMap[predstavaId] = 1;
      this.loadKomentari(predstavaId, 1);
    }
  }

  loadKomentari(predstavaId: number, page: number) {
    this.komentariService.getKomentari(predstavaId, page, this.pageSizeKomentari)
      .subscribe(res => {
        this.komentariMap[predstavaId] = res || { resultList: [], count: 0 };
        this.komentariPageMap[predstavaId] = page;
      });
  }

  prevPage(predstavaId: number) {
    const current = this.komentariPageMap[predstavaId] || 1;
    if (current > 1) this.loadKomentari(predstavaId, current - 1);
  }

  nextPage(predstavaId: number) {
    const current = this.komentariPageMap[predstavaId] || 1;
    const total = Math.ceil((this.komentariMap[predstavaId]?.count || 0) / this.pageSizeKomentari);
    if (current < total) this.loadKomentari(predstavaId, current + 1);
  }

}