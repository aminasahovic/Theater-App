import { ChangeDetectorRef, Component, OnInit, OnDestroy } from '@angular/core';
import { IzvedbaService } from '../../services/izvedba-service ';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { SalaService } from '../../services/sala.service';
import { PredstaveService } from '../../services/predstava.service ';
import { ToastService } from '../../services/toast.service';
import { Subject, switchMap } from 'rxjs';
import { takeUntil, tap } from 'rxjs/operators';

@Component({
  selector: 'app-izvedba-screen',
  templateUrl: './izvedba-screen.html',
  styleUrls: ['./izvedba-screen.css'],
  standalone: false
})
export class IzvedbaScreen implements OnInit, OnDestroy {

  showAddEditPopup = false;
  editMode = false;
  dodajForm!: FormGroup;
  predstave: any[] = [];
  editIzvedbaId: number | null = null;
  loading = false;
  izvedbe: any[] = [];
  sale: any[] = [];
  search = '';
  salaId: number | null = null;
  godina: number | null = null;
  isActive: boolean | null = null;
  page = 1;
  pageSize = 12;
  total = 0;
  get totalPages() { return Math.ceil(this.total / this.pageSize); }
  showFilter = false;
  showDeletePopup = false;
  izvedbaZaBrisanje: any = null;
  godine: number[] = [];
  searchTimeout: any;

  showAddPopup = false;

  private readonly reload$ = new Subject<void>();
  private readonly destroy$ = new Subject<void>();

  constructor(
    private api: IzvedbaService,
    private apiPredstave: PredstaveService,
    private apiSale: SalaService,
    private toast: ToastService,
    private cd: ChangeDetectorRef,
    private fb: FormBuilder
  ) { }

  ngOnInit(): void {
    this.generateGodine();
    this.initDodajForm();
    this.loadPredstave();
    this.loadSale();
    this.setupIzvedbePipeline();
    this.reload$.next();
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  private setupIzvedbePipeline(): void {
    this.reload$.pipe(
      tap(() => {
        this.loading = true;
        this.cd.detectChanges();
      }),
      switchMap(() => {
        const filter: any = { page: this.page, pageSize: this.pageSize };
        if (this.search) filter.search = this.search;
        if (this.salaId) filter.salaId = this.salaId;
        if (this.godina) filter.godina = this.godina;
        if (this.datumIzvodjenja) filter.datumIzvodjenja = this.datumIzvodjenja;
        return this.api.getIzvedbe(filter);
      }),
      takeUntil(this.destroy$)
    ).subscribe({
      next: res => {
        this.izvedbe = res.resultList || [];
        this.total = res.count || 0;
        this.loading = false;
        this.cd.detectChanges();
      },
      error: () => {
        this.izvedbe = [];
        this.total = 0;
        this.loading = false;
        this.cd.detectChanges();
      }
    });
  }

  openAddEditPopup(izvedba?: any) {
    this.showAddEditPopup = true;

    if (izvedba) {
      this.editMode = true;
      this.editIzvedbaId = izvedba.id;

      this.dodajForm.patchValue({
        predstavaId: izvedba.predstavaId,
        salaId: izvedba.salaId,
        datumVrijeme: this.formatDatetimeLocal(izvedba.datumVrijeme),
        cijenaKarte: izvedba.cijenaKarte
      });

    } else {
      this.editMode = false;
      this.editIzvedbaId = null;
      this.dodajForm.reset({ cijenaKarte: 0 });
    }

    this.dodajForm.markAsPristine();
  }

  closeAddEditPopup() {
    this.showAddEditPopup = false;
  }

  initDodajForm() {
    this.dodajForm = this.fb.group({
      predstavaId: [null, Validators.required],
      salaId: [null, Validators.required],
      datumVrijeme: [null, Validators.required],
      cijenaKarte: [0, [Validators.required, Validators.min(0)]]
    });
  }

  generateGodine() {
    const year = new Date().getFullYear();
    this.godine = Array.from({ length: 50 }, (_, i) => year - i);
  }

  loadSale() {
    this.apiSale.getSale().subscribe(res => {
      this.sale = res.resultList;
    });
  }
  loadPredstave() {
    this.apiPredstave.getPredstaveLov().subscribe(res => {
      this.predstave = res.resultList || [];
    });
  }

  loadIzvedbe(): void {
    this.reload$.next();
  }
  datumIzvodjenja: string | null = null;

  applyFilters() { this.page = 1; this.loadIzvedbe(); }
  resetFilters() {
    this.search = ''; this.salaId = null; this.godina = null; this.datumIzvodjenja = null;
    this.applyFilters();
  }
  previousPage() { if (this.page > 1) { this.page--; this.loadIzvedbe(); } }
  nextPage() { if (this.page < this.totalPages) { this.page++; this.loadIzvedbe(); } }
  onSearchChange(value: string) { this.search = value; clearTimeout(this.searchTimeout); this.searchTimeout = setTimeout(() => this.applyFilters(), 300); }

  openDeletePopup(i: any) { this.izvedbaZaBrisanje = i; this.showDeletePopup = true; }
  confirmDelete() {
    if (!this.izvedbaZaBrisanje) return;
    this.api.deleteIzvedba(this.izvedbaZaBrisanje.id).subscribe({
      next: () => {
        this.showDeletePopup = false; this.toast.showSuccess('Izvedba uspješno obrisana.');
        this.loadIzvedbe();
      },
      error: () => { this.showDeletePopup = false; }
    });
  }

  openDodajPopup() {
    this.showAddPopup = true;
    this.dodajForm = this.fb.group({
      predstavaId: [0, Validators.required],
      salaId: [0, Validators.required],
      datumVrijeme: [new Date().toISOString().substring(0, 16), Validators.required],
      cijenaKarte: [0, [Validators.required, Validators.min(0)]]
    });
  }

  saveDodajForm() {
    if (this.dodajForm.invalid) {
      this.dodajForm.markAllAsTouched();
      return;
    }

    const payload = this.dodajForm.value;

    if (this.editMode && this.editIzvedbaId) {

      this.api.updateIzvedba(this.editIzvedbaId, payload).subscribe({
        next: () => {
          this.toast.showSuccess('Izvedba uspješno ažurirana.');
          this.closeAddEditPopup();
          this.loadIzvedbe();
        },
        error: () => {
          this.toast.showError('Greška prilikom ažuriranja izvedbe.');
        }
      });

    } else {

      this.api.dodajIzvedbu(payload).subscribe({
        next: () => {
          this.toast.showSuccess('Izvedba uspješno dodana.');
          this.closeAddEditPopup();
          this.loadIzvedbe();
        },
        error: () => {
          this.toast.showError('Greška prilikom dodavanja izvedbe.');
        }
      });
    }
  }

  formatDatetimeLocal(dt: string) {
    const date = new Date(dt);
    const tzOffset = date.getTimezoneOffset() * 60000;
    return new Date(date.getTime() - tzOffset).toISOString().slice(0, 16);
  }

}