import { Component, OnInit, OnDestroy, ChangeDetectorRef } from '@angular/core';
import { forkJoin, Subject } from 'rxjs';
import { switchMap, takeUntil, tap } from 'rxjs/operators';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { PredstaveService } from '../../services/predstava.service ';
import { Router } from '@angular/router';
import { ToastService } from '../../services/toast.service';

@Component({
  selector: 'app-predstava-screen',
  templateUrl: './predstava-screen.html',
  styleUrls: ['./predstava-screen.css'],
  standalone: false
})
export class PredstavaScreen implements OnInit, OnDestroy {

  loading = false;
  naziv = '';
  zanrId: number | null = null;
  reziserId: number | null = null;
  godina: number | null = null;
  isActive: boolean | null = null;
  showDeletePopup = false;
  predstavaToDelete: any = null;
  zanrovi: any[] = [];
  reziseri: any[] = [];
  godine: number[] = [];
  predstave: any[] = [];
  glumci: any[] = [];
  odabraniGlumci: any[] = [];
  ulogePoGlumcu: { [glumacId: number]: string } = {};

  page = 1;
  pageSize = 12;
  total = 0;
  get totalPages() { return Math.ceil(this.total / this.pageSize); }

  showFilter = false;
  showDodajPopup = false;
  searchTimeout: any;

  private readonly reload$ = new Subject<void>();
  private readonly destroy$ = new Subject<void>();

  dodajForm: FormGroup;
  plakatBase64 = '';

  constructor(
    private api: PredstaveService,
    private cd: ChangeDetectorRef,
    private fb: FormBuilder,
    private router: Router,
    private toast: ToastService
  ) {
    this.dodajForm = this.fb.group({
      naziv: ['', Validators.required],
      opis: ['', Validators.required],
      trajanje: [0, [Validators.required, Validators.min(1)]],
      godina: [new Date().getFullYear(), [Validators.required, Validators.min(1900)]],
      zanrId: [null, Validators.required],
      reziserId: [null, Validators.required],
      isActive: [true],
      plakat: ['']
    });
  }

  ngOnInit(): void {
    this.generateGodine();
    this.loadFilterData();
    this.setupPredstavePipeline();
    this.reload$.next();
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  generateGodine() {
    const year = new Date().getFullYear();
    this.godine = Array.from({ length: 50 }, (_, i) => year - i);
  }

  private loadFilterData(): void {
    forkJoin({
      zanrovi: this.api.getZanrovi(),
      reziseri: this.api.getReziseri(),
      glumci: this.api.getGlumci()
    }).pipe(takeUntil(this.destroy$)).subscribe({
      next: ({ zanrovi, reziseri, glumci }) => {
        this.zanrovi = zanrovi;
        this.reziseri = reziseri;
        this.glumci = glumci;
      }
    });
  }

  private setupPredstavePipeline(): void {
    this.reload$.pipe(
      tap(() => {
        this.loading = true;
        this.cd.detectChanges();
      }),
      switchMap(() => this.api.getPredstave({
        naziv: this.naziv,
        zanrId: this.zanrId,
        reziserId: this.reziserId,
        godina: this.godina,
        isActive: this.isActive,
        page: this.page,
        pageSize: this.pageSize
      })),
      takeUntil(this.destroy$)
    ).subscribe({
      next: res => {
        this.predstave = Array.isArray(res.resultList) ? res.resultList : [];
        this.total = typeof res.count === 'number' ? res.count : 0;
        this.loading = false;
        this.cd.detectChanges();
      },
      error: () => {
        this.predstave = [];
        this.total = 0;
        this.loading = false;
        this.cd.detectChanges();
      }
    });
  }
  onGlumacOdabran(event: any) {
    const id = Number(event.target.value);
    if (!id) return;

    const gl = this.glumci.find(x => x.id === id);
    if (!gl) return;

    if (!this.odabraniGlumci.some(g => g.id === id)) {
      this.odabraniGlumci.push(gl);
    }
  }
  ukloniGlumca(gl: any) {
    this.odabraniGlumci = this.odabraniGlumci.filter(g => g.id !== gl.id);
    delete this.ulogePoGlumcu[gl.id];
  }


  loadPredstave(): void {
    this.reload$.next();
  }

  applyFilters() {
    this.page = 1;
    this.loadPredstave();
  }

  resetFilters() {
    this.naziv = '';
    this.zanrId = null;
    this.reziserId = null;
    this.godina = null;
    this.isActive = null;
    this.applyFilters();
  }

  previousPage() {
    if (this.page > 1) {
      this.page--;
      this.loadPredstave();
    }
  }

  nextPage() {
    if (this.page < this.totalPages) {
      this.page++;
      this.loadPredstave();
    }
  }

  onNazivChange(value: string) {
    this.naziv = value;
    clearTimeout(this.searchTimeout);
    this.searchTimeout = setTimeout(() => this.applyFilters(), 300);
  }
  openDodajPopup() {
    this.dodajForm.reset({
      isActive: true,
      godina: new Date().getFullYear(),
      trajanje: 0
    });
    this.plakatBase64 = '';

    if (this.zanrovi.length > 0 && this.reziseri.length > 0) {
      this.showDodajPopup = true;
    } else {
      forkJoin({
        zanrovi: this.api.getZanrovi(),
        reziseri: this.api.getReziseri()
      }).subscribe({
        next: ({ zanrovi, reziseri }) => {
          this.zanrovi = Array.isArray(zanrovi) ? zanrovi : [];
          this.reziseri = Array.isArray(reziseri) ? reziseri : [];
          this.showDodajPopup = true;
        },
        error: () => {
          this.zanrovi = [];
          this.reziseri = [];
          this.showDodajPopup = true;
        }
      });
    }
  }


  onSlikaSelected(event: any) {
    const file: File = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = () => this.plakatBase64 = (reader.result as string).split(',')[1];
      reader.readAsDataURL(file);
    }
  }

  dodajPredstavu() {
    if (this.dodajForm.invalid) return;

    const nova = { ...this.dodajForm.value, plakat: this.plakatBase64 };

    this.api.dodajPredstavu(nova).subscribe({
      next: (predstava) => {
        this.odabraniGlumci.forEach(g => {
          const body = {
            glumacId: g.id,
            predstavaId: predstava.id,
            uloga: this.ulogePoGlumcu[g.id]
          };
          this.api.dodajGlumcaPredstavi(body).subscribe();
        });

        this.showDodajPopup = false;
        this.loadPredstave();
        this.toast.showSuccess("Predstava uspješno dodana!");
      },
      error: (err) => {
        console.error(err);
        this.showDodajPopup = false;
        this.toast.showError('Greška pri dodavanju predstave!');
      }
    });
  }


  predstavaZaBrisanje: any = null;

  openDeletePopup(predstava: any) {
    this.predstavaZaBrisanje = predstava;
    this.showDeletePopup = true;
  }

  confirmDelete() {
    if (!this.predstavaZaBrisanje) return;

    this.api.deletePredstavu(this.predstavaZaBrisanje.id).subscribe({
      next: () => {
        this.showDeletePopup = false;
        this.toast.showSuccess('Predstava je obrisana!');

        this.loadPredstave();
      },
      error: (err) => {
        console.error(err);
        this.showDeletePopup = false;
        this.toast.showSuccess('Greška pri brisanju predstave!');

      }
    });
  }

  openDetails(id: number) {
    this.router.navigate(['/predstave', id]);
  }
}
