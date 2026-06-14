import { ChangeDetectorRef, Component, OnInit, OnDestroy } from '@angular/core';
import { RepertoarService } from '../../services/repertoar.service';
import { IzvedbaService } from '../../services/izvedba-service ';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { forkJoin, Observable, of, Subject, switchMap } from 'rxjs';
import { takeUntil, tap } from 'rxjs/operators';
import { Router } from '@angular/router';
import { ToastService } from '../../services/toast.service';

@Component({
  selector: 'app-repertoar-screen',
  templateUrl: './repertoar-screen.html',
  styleUrls: ['./repertoar-screen.css'],
  standalone: false
})
export class RepertoarScreen implements OnInit, OnDestroy {
  repertoarForm!: FormGroup;

  repertoari: any[] = [];
  repertoarIzvedbe: any[] = [];
  availableIzvedbe: any[] = [];
  showAddPopup = false;
  editingRepertoar: any = null;
  searchNaziv = '';
  datumFilter: string | null = null;

  expandedRepertoarId: number | null = null;

  page = 1;
  pageSize = 6;
  total = 0;

  loading = false;
  canLoadIzvedbe = false;

  showDeletePopup = false;
  repertoarToDelete: any = null;
  private readonly reload$ = new Subject<void>();
  private readonly destroy$ = new Subject<void>();

  showReportPopup = false;
  reportLoading = false;
  selectedReport: any = null;

  constructor(
    private api: RepertoarService,
    private cd: ChangeDetectorRef,
    private fb: FormBuilder,
    private izvedbaService: IzvedbaService,
    private toast: ToastService,
    private router: Router
  ) { }

  ngOnInit(): void {
    this.setupRepertoarPipeline();
    this.reload$.next();
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  private setupRepertoarPipeline(): void {
    this.reload$.pipe(
      tap(() => {
        this.loading = true;
        this.cd.detectChanges();
      }),
      switchMap(() => {
        const filter: any = { page: this.page, pageSize: this.pageSize };
        if (this.searchNaziv) filter.naziv = this.searchNaziv;
        if (this.datumFilter) filter.pocetakDatum = this.datumFilter;
        return this.api.getRepertoari(filter);
      }),
      takeUntil(this.destroy$)
    ).subscribe({
      next: res => {
        this.repertoari = res.resultList || [];
        this.total = res.count || 0;
        this.loading = false;
        this.cd.detectChanges();
      },
      error: () => {
        this.repertoari = [];
        this.total = 0;
        this.loading = false;
        this.cd.detectChanges();
      }
    });
  }

  get totalPages() {
    return Math.ceil(this.total / this.pageSize);
  }

  loadRepertoari(): void {
    this.reload$.next();
  }

  toggleExpand(repertoar: any) {
    if (this.expandedRepertoarId === repertoar.id) {
      this.expandedRepertoarId = null;
      this.repertoarIzvedbe = [];
    } else {
      this.expandedRepertoarId = repertoar.id;
      this.loadRepertoarIzvedbe(repertoar.id);
    }
  }

  loadRepertoarIzvedbe(repertoarId: number) {
    this.repertoarIzvedbe = [];
    this.api.getRepertoarIzvedbe(repertoarId).subscribe({
      next: res => {
        this.repertoarIzvedbe = this.resultList(res);
        this.cd.detectChanges();
      },
      error: () => {
        this.repertoarIzvedbe = [];
        this.cd.detectChanges();
      }
    });
  }

  applyFilters() {
    this.page = 1;
    this.loadRepertoari();
  }

  resetFilters() {
    this.searchNaziv = '';
    this.datumFilter = null;
    this.page = 1;
    this.loadRepertoari();
  }

  previousPage() {
    if (this.page > 1) { this.page--; this.loadRepertoari(); }
  }

  nextPage() {
    if (this.page < this.totalPages) { this.page++; this.loadRepertoari(); }
  }

  openAddPopup() {
    this.showAddPopup = true;
    this.editingRepertoar = null;
    this.availableIzvedbe = [];

    this.repertoarForm = this.fb.group({
      naziv: ['', Validators.required],
      pocetakDatum: ['', [Validators.required, this.futureDateValidator]],
      krajDatum: ['', Validators.required]
    });

    this.repertoarForm.statusChanges.subscribe(() => {
      this.canLoadIzvedbe = this.repertoarForm.valid;
    });

    const pocetak = this.repertoarForm.get('pocetakDatum')?.value;
    const kraj = this.repertoarForm.get('krajDatum')?.value;
    if (pocetak && kraj) {
      this.loadAvailableIzvedbe();
    }
  }

  closeAddPopup() {
    this.showAddPopup = false;
    this.editingRepertoar = null;
    this.availableIzvedbe = [];
    if (this.repertoarForm) {
      this.repertoarForm.reset();
    }
    this.canLoadIzvedbe = false;
  }


  private refreshAfterSaveSuccess(message: string) {
    this.closeAddPopup();
    this.cd.detectChanges();
    queueMicrotask(() => {
      this.toast.showSuccess(message);
      this.reload$.next();
      this.cd.detectChanges();
    });
  }

  futureDateValidator(control: any) {
    if (!control.value) return null;
    const selected = new Date(control.value);
    return selected <= new Date() ? { pastDate: true } : null;
  }

  loadAvailableIzvedbe() {
    if (!this.canLoadIzvedbe) return;

    const pocetak = this.repertoarForm.get('pocetakDatum')?.value;
    const kraj = this.repertoarForm.get('krajDatum')?.value;

    const pocetakDate = new Date(pocetak);
    const krajDate = new Date(kraj);

    this.izvedbaService.getIzvedbePeriod(pocetakDate.toISOString(), krajDate.toISOString())
      .subscribe({
        next: res => {
          this.availableIzvedbe = (res || []).map(i => ({ ...i, odabrano: false }));
          this.cd.detectChanges();
        },
        error: () => this.availableIzvedbe = []
      });
  }

  private izvedbaId(e: { izvedbaId?: number; IzvedbaId?: number }): number {
    return e.izvedbaId ?? e.IzvedbaId ?? 0;
  }
  private repertoarIzvedbaPovezId(e: {
    repertoarIzvedbaId?: number;
    RepertoarIzvedbaId?: number;
  }): number {
    return e.repertoarIzvedbaId ?? e.RepertoarIzvedbaId ?? 0;
  }

  private getRepertoarEntityId(r: { id?: number; Id?: number } | null): number {
    if (!r) return 0;
    const v = (r as { id?: number; Id?: number }).id ?? (r as { id?: number; Id?: number }).Id;
    const n = Number(v);
    return Number.isFinite(n) && n > 0 ? n : 0;
  }

  private resultList(izv: any): any[] {
    if (!izv) return [];
    return izv.resultList ?? izv.ResultList ?? [];
  }

  saveRepertoar() {
    if (!this.repertoarForm) return;
    if (this.repertoarForm.invalid) {
      this.repertoarForm.markAllAsTouched();
      this.toast.showError('Popunite sva obavezna polja ispravno prije spremanja.');
      this.cd.detectChanges();
      return;
    }

    const data = this.repertoarForm.value;

    if (this.editingRepertoar) {
      const repertoarId = this.getRepertoarEntityId(this.editingRepertoar);
      if (!repertoarId) {
        this.toast.showError('Nije moguće odrediti ID repertoara. Osvježite stranicu i pokušajte ponovo.');
        return;
      }
      this.api.updateRepertoar(repertoarId, data).subscribe({
        next: () => {
          this.api.getRepertoarIzvedbe(repertoarId).subscribe({
            next: repertoarIzv => {
              const existing = this.resultList(repertoarIzv);
              const selectedIds = this.availableIzvedbe
                .filter(i => i.odabrano)
                .map(i => this.izvedbaId(i as { izvedbaId?: number; IzvedbaId?: number }));

              const toAdd = selectedIds.filter(
                id => !existing.some((e: any) => this.izvedbaId(e) === id)
              );
              const toRemove = existing.filter(
                (e: any) => !selectedIds.includes(this.izvedbaId(e))
              );

              const removeObservables = toRemove
                .map((e: any) => this.repertoarIzvedbaPovezId(e))
                .filter(id => id > 0)
                .map(id => this.api.deleteRepertoarIzvedba(id));
              const addObservables = toAdd.map(id =>
                this.api.addRepertoarIzvedba({ repertoarId, izvedbaId: id })
              );

             const syncOps = [...addObservables, ...removeObservables];
const afterSync$: Observable<any> = syncOps.length > 0 ? forkJoin(syncOps) : of(void 0);
afterSync$.subscribe({
                next: () => {
                  this.refreshAfterSaveSuccess('Repertoar uspješno ažuriran!');
                },
                error: () => {
                  this.toast.showError('Osnovni podaci repertoara su sačuvani, ali ažuriranje veza s izvedbama nije uspjelo.');
                  this.refreshAfterSaveSuccess('Repertoar ažuriran. Provjerite povezane izvedbe.');
                }
              });
            },
            error: () => {
              this.refreshAfterSaveSuccess('Repertoar uspješno ažuriran! (Lista izvedbi trenutno nije učitana — osvježite stranicu ako treba).');
            }
          });
        },
        error: () => this.toast.showError('Greška pri ažuriranju repertoara!')
      });
    } else {
      this.api.addRepertoar(data).subscribe({
        next: (repertoarObj: any) => {
          const o = repertoarObj;
          const rid =
            typeof o === 'number' && !Number.isNaN(o)
              ? o
              : Number(o && typeof o === 'object' ? (o as any).id ?? (o as any).Id ?? 0 : 0);
          const repertoarId = Number.isFinite(rid) && rid > 0 ? rid : 0;
          const selectedIzvedbe = this.availableIzvedbe.filter(i => i.odabrano);

          if (selectedIzvedbe.length > 0) {
            if (!repertoarId) {
              this.toast.showError('Repertoar je kreiran, ali ID nije vraćen. Osvježite stranicu i dodajte izvedbe ručno.');
              this.refreshAfterSaveSuccess('Repertoar dodan. Provjerite povezivanje izvedbi.');
              return;
            }
            const observables = selectedIzvedbe.map(i =>
              this.api.addRepertoarIzvedba({
                repertoarId,
                izvedbaId: this.izvedbaId(i as { izvedbaId?: number; IzvedbaId?: number })
              })
            );
           const after$: Observable<any> = observables.length ? forkJoin(observables) : of(void 0);
after$.subscribe({
              next: () => this.refreshAfterSaveSuccess('Repertoar uspješno dodan!'),
              error: () => {
                this.toast.showError('Repertoar je kreiran, ali dio izvedbi nije povezan.');
                this.refreshAfterSaveSuccess('Repertoar dodan, provjerite povezane izvedbe.');
              }
            });
          } else {
            this.refreshAfterSaveSuccess('Repertoar uspješno dodan!');
          }
        },
        error: () => this.toast.showError('Greška pri dodavanju repertoara!')
      });
    }
  }


  private formatForInput(dateStr: string) {
    if (dateStr == null || String(dateStr).trim() === '') return '';
    const d = new Date(dateStr);
    if (Number.isNaN(d.getTime())) return '';
    const tzOffset = d.getTimezoneOffset() * 60000;
    return new Date(d.getTime() - tzOffset).toISOString().slice(0, 16);
  }

  openEditPopup(r: any) {
    this.showAddPopup = true;
    this.editingRepertoar = r;
    this.availableIzvedbe = [];
    this.canLoadIzvedbe = true;

    this.repertoarForm = this.fb.group({
      naziv: [r.naziv, Validators.required],
      pocetakDatum: [this.formatForInput(r.pocetakDatum), Validators.required],
      krajDatum: [this.formatForInput(r.krajDatum), Validators.required]
    });

    const pocetakDate = new Date(r.pocetakDatum);
    const krajDate = new Date(r.krajDatum);

    this.izvedbaService.getIzvedbePeriod(pocetakDate.toISOString(), krajDate.toISOString())
      .subscribe({
        next: res => {
          const izvedbe = res || [];
          this.api.getRepertoarIzvedbe(r.id).subscribe({
            next: repertoarIzv => {
              const odabrane = (repertoarIzv?.resultList || []).map((x: any) => ({
                izvedbaId: this.izvedbaId(x),
                repertoarIzvedbaId: this.repertoarIzvedbaPovezId(x)
              }));

              this.availableIzvedbe = izvedbe.map(i => {
                const iid = this.izvedbaId(i as { izvedbaId?: number; IzvedbaId?: number });
                const match = odabrane.find((o:any) => o.izvedbaId === iid);
                return {
                  ...i,
                  odabrano: !!match,
                  repertoarIzvedbaId: match?.repertoarIzvedbaId
                };
              });

              this.cd.detectChanges();
            },
            error: () => { this.availableIzvedbe = izvedbe.map(i => ({ ...i, odabrano: false })); }
          });
        },
        error: () => this.availableIzvedbe = []
      });
  }


deleteRepertoar(r: any) {
  this.repertoarToDelete = r;
  this.showDeletePopup = true;
}
confirmDelete() {
  if (!this.repertoarToDelete) return;

  this.api.deleteRepertoar(this.repertoarToDelete.id).subscribe({
    next: () => {
      this.toast.showSuccess('Repertoar uspješno obrisan!');
      this.showDeletePopup = false;
      this.repertoarToDelete = null;
      this.loadRepertoari();
    },
    error: () => {
      this.toast.showError('Greška pri brisanju repertoara!');
    }
  });
}closeDelete() {
  this.showDeletePopup = false;
  this.repertoarToDelete = null;
}

  openPredstavaDetails(izvedba: any) {
    if (!izvedba?.predstavaId) { return; }
    this.router.navigate(['/predstave', izvedba.predstavaId]);
  }

  openSalesReport(izvedba: any) {
    this.showReportPopup = true;
    this.reportLoading = true;
    this.selectedReport = null;

    const izvedbaId =
      izvedba?.izvedbaId ??
      izvedba?.IzvedbaId ??
      izvedba?.id ??
      null;

    if (!izvedbaId) {
      this.reportLoading = false;
      this.toast.showError('Nije moguće odrediti ID izvedbe za izvještaj.');
      return;
    }

    this.api.getTicketSalesReport(izvedbaId).subscribe({
      next: (res) => {
        this.selectedReport = res;
        this.reportLoading = false;
        this.cd.detectChanges();
      },
      error: () => {
        this.reportLoading = false;
        this.showReportPopup = false;
        this.toast.showError('Greška pri dohvaćanju izvještaja prodaje!');
      }
    });
  }

  closeReportPopup() {
    this.showReportPopup = false;
    this.selectedReport = null;
  }

  printReport() {
    window.print();
  }
}
