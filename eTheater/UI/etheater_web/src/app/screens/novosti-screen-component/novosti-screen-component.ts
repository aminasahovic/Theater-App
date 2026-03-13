import { ChangeDetectorRef, Component, OnInit, OnDestroy } from '@angular/core';
import { Novost, NovostiService } from '../../services/novosti.service';
import { FormBuilder, FormControl, FormGroup, Validators } from '@angular/forms';
import { debounceTime, Subject, switchMap } from 'rxjs';
import { takeUntil, tap } from 'rxjs/operators';
import { ToastService } from '../../services/toast.service';

@Component({
  selector: 'app-novosti-screen-component',
  templateUrl: './novosti-screen-component.html',
  styleUrls: ['./novosti-screen-component.css'],
  standalone: false
})
export class NovostiScreenComponent implements OnInit, OnDestroy {
  novosti: Novost[] = [];
  loading = false;
  total = 0;
  page = 1;
  pageSize = 8;
  searchForm: FormGroup;
  selectedDate?: string | null;

  private readonly reload$ = new Subject<void>();
  private readonly destroy$ = new Subject<void>();

  showPopup = false;
  popupForm!: FormGroup;
  isEditMode = false;
  selectedNovost: Novost | null = null;
  plakatBase64: string = '';

  constructor(
    private novostiService: NovostiService,
    private fb: FormBuilder,
    private cd: ChangeDetectorRef,
    private toast: ToastService

  ) {
    this.searchForm = this.fb.group({
      naslov: [''],
      datumObjave: ['']
    });
  }

  ngOnInit(): void {
    this.setupNovostiPipeline();

    this.naslov.valueChanges.pipe(debounceTime(300), takeUntil(this.destroy$)).subscribe(() => {
      this.page = 1;
      this.reload$.next();
    });

    this.datumObjave.valueChanges.pipe(takeUntil(this.destroy$)).subscribe(() => {
      this.page = 1;
      this.selectedDate = this.datumObjave.value || null;
      this.reload$.next();
    });

    this.reload$.next();
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  private setupNovostiPipeline(): void {
    this.reload$.pipe(
      tap(() => {
        this.loading = true;
        this.cd.detectChanges();
      }),
      switchMap(() => this.novostiService.getNovosti({
        page: this.page,
        pageSize: this.pageSize,
        naslov: this.naslov.value,
        datumObjave: this.selectedDate || null
      })),
      takeUntil(this.destroy$)
    ).subscribe({
      next: res => {
        this.novosti = res.data;
        this.total = res.count;
        this.loading = false;
        this.cd.detectChanges();
      },
      error: () => {
        this.novosti = [];
        this.total = 0;
        this.loading = false;
        this.cd.detectChanges();
      }
    });
  }

  get naslov(): FormControl {
    return this.searchForm.get('naslov') as FormControl;
  }

  get datumObjave(): FormControl {
    return this.searchForm.get('datumObjave') as FormControl;
  }

  loadNovosti(): void {
    this.reload$.next();
  }

  resetFilters(): void {
    this.searchForm.reset();
    this.selectedDate = null;
    this.page = 1;
    this.loadNovosti();
  }

  previousPage(): void {
    if (this.page > 1) { this.page--; this.loadNovosti(); }
  }

  nextPage(): void {
    if (this.page < this.totalPages) { this.page++; this.loadNovosti(); }
  }

  get totalPages(): number {
    return Math.ceil(this.total / this.pageSize);
  }

  openAddDialog(): void {
    this.isEditMode = false;
    this.selectedNovost = null;
    this.plakatBase64 = '';
    this.initPopupForm();
    this.showPopup = true;
  }

  openEditDialog(novost: Novost): void {
    this.isEditMode = true;
    this.selectedNovost = novost;
    this.plakatBase64 = novost.slika || '';
    this.initPopupForm(novost);
    this.showPopup = true;
  }

  initPopupForm(novost?: Novost) {
    const todayStr = new Date().toISOString().split('T')[0];
    this.popupForm = this.fb.group({
      naslov: [novost?.naslov || '', Validators.required],
      sadrzaj: [novost?.sadrzaj || '', Validators.required],
      datumObjave: [novost ? novost.datumObjave.split('T')[0] : todayStr, Validators.required],
      slika: [novost?.slika || '', Validators.required]
    });
  }


  onSlikaSelected(event: any) {
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = () => {
        this.plakatBase64 = (reader.result as string).split(',')[1];
        this.popupForm.patchValue({ slika: this.plakatBase64 });
      };
      reader.readAsDataURL(file);
    }
  }

  saveNovost() {
    if (this.popupForm.invalid) {
      this.popupForm.markAllAsTouched();
      return;
    }

    const formValue = this.popupForm.value;
    const novostData: Partial<Novost> = {
      naslov: formValue.naslov,
      sadrzaj: formValue.sadrzaj,
      datumObjave: formValue.datumObjave,
      slika: formValue.slika,
      id: this.selectedNovost?.id
    };


    if (this.isEditMode && this.selectedNovost) {
      this.novostiService.updateNovost(novostData as Novost).subscribe(() => {
        this.showPopup = false;
        this.toast.showSuccess('Novost uspješno uređena');

        this.loadNovosti();
      });
    } else {
      this.novostiService.dodajNovost(novostData).subscribe(() => {
        this.showPopup = false;
        this.toast.showSuccess('Novost uspješno dodana');

        this.loadNovosti();
      });
    }
  }

  closePopup() {
    this.showPopup = false;
  }

  isValidBase64(str?: string | null): boolean {
    if (!str || str.trim().toLowerCase() === 'string') return false;
    try { atob(str); return true; } catch { return false; }
  }
  showDeletePopup = false;
  novostZaBrisanje: Novost | null = null;
  confirmDelete(novost: Novost): void {
    this.novostZaBrisanje = novost;
    this.showDeletePopup = true;
  }
  cancelDelete() {
    this.showDeletePopup = false;
    this.novostZaBrisanje = null;
  }

  deleteConfirmed() {
    if (!this.novostZaBrisanje) return;

    this.novostiService.deleteNovost(this.novostZaBrisanje.id).subscribe({
      next: () => {
        this.showDeletePopup = false;
        this.toast.showSuccess('Novost uspješno obrisana');
        this.loadNovosti();
      },
      error: () => {
        this.toast.showError('Greška pri brisanju novosti');
      }
    });
  }

}