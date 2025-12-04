import { ChangeDetectorRef, Component } from '@angular/core';
import { Reziser } from '../../models/models';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { InsertReziser, ReziserService } from '../../services/reziser.service';
import { ToastService } from '../../services/toast.service';

@Component({
  selector: 'app-reziseri-screen',
  templateUrl: './reziseri-screen.html',
  styleUrls: ['./reziseri-screen.css'],
  standalone:false
})
export class ReziseriScreen {  reziseri: Reziser[] = [];
  loading = false;

  ime = '';
  page = 1;
  pageSize = 12;
  totalCount = 0;

  showEditPopup = false;
  editMode = false;
  editForm!: FormGroup;
  currentEditId?: number;

  showDeletePopup = false;
  reziserToDelete?: Reziser;

  constructor(
    private reziserService: ReziserService,
    private fb: FormBuilder,
    private cd: ChangeDetectorRef,
    private toast: ToastService
  ) {
    this.editForm = this.fb.group({
      ime: ['', [Validators.required, Validators.pattern(/^[A-ZČĆŽŠĐ][a-zčćžšđ]+$/)]],
      prezime: ['', [Validators.required, Validators.pattern(/^[A-ZČĆŽŠĐ][a-zčćžšđ]+$/)]]
    });
  }

  ngOnInit(): void { this.loadReziseri(); }

  loadReziseri() {
    this.loading = true;
    this.reziserService.getReziseri(this.ime, this.page, this.pageSize).subscribe({
      next: res => { this.reziseri = res.data; this.totalCount = res.total; this.loading = false; this.cd.detectChanges(); },
      error: () => { this.reziseri = []; this.totalCount = 0; this.loading = false; this.cd.detectChanges(); }
    });
  }

  onImeChange(val: string) { this.ime = val; this.page = 1; this.loadReziseri(); }

  prevPage() { if (this.page > 1) { this.page--; this.loadReziseri(); } }
  nextPage() { if (this.page < this.totalPages) { this.page++; this.loadReziseri(); } }
  get totalPages() { return Math.ceil(this.totalCount / this.pageSize); }

  openEditPopup(reziser?: Reziser) {
    this.editMode = !!reziser;
    this.showEditPopup = true;
    if (reziser) { this.currentEditId = reziser.id; this.editForm.patchValue({ ime: reziser.ime, prezime: reziser.prezime }); }
    else { this.currentEditId = undefined; this.editForm.reset(); }
  }

  closeEditPopup() { this.showEditPopup = false; this.editForm.reset(); }

  submitEdit() {
    if (this.editForm.invalid) return;

    const val = this.editForm.value;
    const reziserData: InsertReziser = { ime: val.ime, prezime: val.prezime };

    if (this.editMode && this.currentEditId) {
      this.reziserService.updateReziser(this.currentEditId, reziserData).subscribe(() => {
        this.toast.showSuccess("Režiser ažuriran!"); this.closeEditPopup(); this.loadReziseri();
      });
    } else {
      this.reziserService.dodajReziser(reziserData).subscribe(() => {
        this.toast.showSuccess("Režiser dodan!"); this.closeEditPopup(); this.loadReziseri();
      });
    }
  }

  deleteReziser(reziser: Reziser) { this.reziserToDelete = reziser; this.showDeletePopup = true; }

  confirmDelete() {
    if (!this.reziserToDelete) return;
    this.reziserService.deleteReziser(this.reziserToDelete.id).subscribe(() => {
      this.toast.showSuccess("Režiser obrisan!"); this.showDeletePopup = false; this.loadReziseri();
    });
  }

  closeDelete() { this.showDeletePopup = false; this.reziserToDelete = undefined; }
}