import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { RepertoarService } from '../../services/repertoar.service';
import { IzvedbaService } from '../../services/izvedba-service ';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { forkJoin } from 'rxjs';
import { ToastService } from '../../services/toast.service';

@Component({
  selector: 'app-repertoar-screen',
  templateUrl: './repertoar-screen.html',
  styleUrls: ['./repertoar-screen.css'],
  standalone: false
})
export class RepertoarScreen implements OnInit {
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

  constructor(
    private api: RepertoarService,
    private cd: ChangeDetectorRef,
    private fb: FormBuilder,
    private izvedbaService: IzvedbaService,
    private toast: ToastService
  ) { }

  ngOnInit(): void {
    this.loadRepertoari();
  }

  get totalPages() {
    return Math.ceil(this.total / this.pageSize);
  }

  loadRepertoari() {
    this.loading = true;

    const filter: any = { page: this.page, pageSize: this.pageSize };
    if (this.searchNaziv) filter.naziv = this.searchNaziv;
    if (this.datumFilter) filter.pocetakDatum = this.datumFilter;

    this.api.getRepertoari(filter).subscribe({
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
        this.repertoarIzvedbe = res?.resultList || [];
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

    // enable/disable load button
    this.repertoarForm.statusChanges.subscribe(() => {
      this.canLoadIzvedbe = this.repertoarForm.valid;
    });

    // odmah učitaj izvedbe ako su datumi validni
    const pocetak = this.repertoarForm.get('pocetakDatum')?.value;
    const kraj = this.repertoarForm.get('krajDatum')?.value;
    if (pocetak && kraj) {
      this.loadAvailableIzvedbe();
    }
  }

  closeAddPopup() {
    this.showAddPopup = false;
    this.availableIzvedbe = [];
    this.repertoarForm.reset();
    this.canLoadIzvedbe = false;
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

  saveRepertoar() {
    if (this.repertoarForm.invalid) return;

    const data = this.repertoarForm.value;

    if (this.editingRepertoar) {
      const repertoarId = this.editingRepertoar.id;
      console.log(repertoarId);
      this.api.updateRepertoar(repertoarId, data).subscribe({
        next: () => {
          this.api.getRepertoarIzvedbe(repertoarId).subscribe({
            next: repertoarIzv => {
              const existing = repertoarIzv?.resultList || [];
              const selectedIds = this.availableIzvedbe.filter(i => i.odabrano).map(i => i.izvedbaId);
              console.log(selectedIds);

              const toAdd = selectedIds.filter(id => !existing.some((e: any) => e.izvedbaId === id));
              const toRemove = existing
                .filter((e: any) => !selectedIds.includes(e.izvedbaId)); 

              console.log(toRemove);
              const removeObservables = toRemove.map((e: any) =>
                this.api.deleteRepertoarIzvedba(e.repertoarIzvedbaId)
              );
              console.log(toRemove);

              const addObservables = toAdd.map(id => this.api.addRepertoarIzvedba({ repertoarId, izvedbaId: id }));

              forkJoin([...addObservables, ...removeObservables]).subscribe({
                next: () => {
                  this.toast.showSuccess('Repertoar uspješno ažuriran!');
                  this.refreshAfterAdd();
                },
                error: () => this.toast.showError('Greška pri ažuriranju izvedbi!')
              });
            },
            error: () => this.toast.showError('Greška pri učitavanju izvedbi repertoara!')
          });
        },
        error: () => this.toast.showError('Greška pri ažuriranju repertoara!')
      });
    } else {
      // ADD
      this.api.addRepertoar(data).subscribe({
        next: (repertoarObj: any) => {
          const repertoarId = Number(repertoarObj.id);
          const selectedIzvedbe = this.availableIzvedbe.filter(i => i.odabrano);

          if (selectedIzvedbe.length > 0) {
            const observables = selectedIzvedbe.map(i =>
              this.api.addRepertoarIzvedba({ repertoarId, izvedbaId: i.izvedbaId })
            );

            forkJoin(observables).subscribe({
              next: () => {
                this.toast.showSuccess('Repertoar uspješno dodan!');
                this.refreshAfterAdd();
              },
              error: () => this.toast.showError('Greška pri dodavanju izvedbi!')
            });
          } else {
            this.toast.showSuccess('Repertoar uspješno dodan!');
            this.refreshAfterAdd();
          }
        },
        error: () => this.toast.showError('Greška pri dodavanju repertoara!')
      });
    }
  }

  private refreshAfterAdd() {
    this.closeAddPopup();
    setTimeout(() => this.loadRepertoari(), 200);
  }

  private formatForInput(dateStr: string) {
    const d = new Date(dateStr);
    const tzOffset = d.getTimezoneOffset() * 60000; // offset in ms
    return new Date(d.getTime() - tzOffset).toISOString().slice(0, 16); // yyyy-MM-ddTHH:mm
  }

  openEditPopup(r: any) {
    this.showAddPopup = true;
    this.editingRepertoar = r;
    this.availableIzvedbe = [];
    this.canLoadIzvedbe = true;

    this.repertoarForm = this.fb.group({
      naziv: [r.naziv, Validators.required],
      pocetakDatum: [this.formatForInput(r.pocetakDatum), [Validators.required, this.futureDateValidator]],
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
                izvedbaId: x.izvedbaId,
                repertoarIzvedbaId: x.id
              }));

              this.availableIzvedbe = izvedbe.map(i => {
                const match = odabrane.find((o: any) => o.izvedbaId === i.izvedbaId);
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
}
