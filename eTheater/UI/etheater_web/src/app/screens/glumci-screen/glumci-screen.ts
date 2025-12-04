import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { Glumac, GlumciService, InsertGlumac } from '../../services/glumci.service';
import { FormBuilder, FormGroup } from '@angular/forms';
import { ToastService } from '../../services/toast.service';

@Component({
  selector: 'app-glumci-screen',
  templateUrl: './glumci-screen.html',
  styleUrls: ['./glumci-screen.css'],
  standalone: false
})
export class GlumciScreen implements OnInit {

  glumci: Glumac[] = [];
  loading = false;

  ime = '';
  page = 1;
  pageSize = 12;
  totalCount = 0;

  showEditPopup = false;
  editMode = false;
  editForm!: FormGroup;
  currentEditId?: number;
  slikaBase64?: string;

  showDeletePopup = false;
  glumacToDelete?: Glumac;


  constructor(private glumciService: GlumciService, private fb: FormBuilder,private cd: ChangeDetectorRef,  private toast: ToastService) {
    this.editForm = this.fb.group({
      ime: [''],
      prezime: ['']
    });
  }

  ngOnInit(): void {
    this.loadGlumci();
  }
loadGlumci() {
  this.loading = true;
  this.glumciService.getGlumci(this.ime, this.page, this.pageSize).subscribe({
    next: res => {
      this.glumci = res.data;
      this.totalCount = res.total;
      this.loading = false;
      this.cd.detectChanges(); 
    },
    error: () => {
      this.glumci = [];
      this.totalCount = 0;
      this.loading = false;
      this.cd.detectChanges(); 
    }
  });
}


  onImeChange(val: string) {
    this.ime = val;
    this.page = 1;
    this.loadGlumci();
  }

  prevPage() { if (this.page > 1) { this.page--; this.loadGlumci(); } }
  nextPage() { if (this.page < this.totalPages) { this.page++; this.loadGlumci(); } }
  get totalPages() { return Math.ceil(this.totalCount / this.pageSize); }

  openEditPopup(glumac?: Glumac) {
    this.editMode = !!glumac;
    this.showEditPopup = true;

    if (glumac) {
      this.currentEditId = glumac.id;
      this.editForm.patchValue({ ime: glumac.ime, prezime: glumac.prezime });
      this.slikaBase64 = glumac.slika;
    } else {
      this.currentEditId = undefined;
      this.editForm.reset();
      this.slikaBase64 = undefined;
    }
  }

  closeEditPopup() { this.showEditPopup = false; this.editForm.reset(); this.slikaBase64 = undefined; }

  onFileChange(event: any) {
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = () => this.slikaBase64 = reader.result as string;
      reader.readAsDataURL(file);
    }
  }

  submitEdit() {
    if (!this.editForm.valid) return alert("Popunite polja!");

    const val = this.editForm.value;
    const glumacData: InsertGlumac = { ime: val.ime, prezime: val.prezime, slika: this.slikaBase64 };

    if (this.editMode && this.currentEditId) {
      this.glumciService.updateGlumca(this.currentEditId, glumacData).subscribe(() => {
        this.toast.showSuccess("Glumac ažuriran!");
        this.closeEditPopup();
        this.loadGlumci();
      });
    } else {
      this.glumciService.dodajGlumca(glumacData).subscribe(() => {
        this.toast.showSuccess("Glumac dodan!");
        this.closeEditPopup();
        this.loadGlumci();
      });
    }
  }

  deleteGlumac(glumac: Glumac) {
    this.glumacToDelete = glumac;
    this.showDeletePopup = true;
  }

  confirmDelete() {
    if (!this.glumacToDelete) return;
    this.glumciService.deleteGlumca(this.glumacToDelete.id).subscribe(() => {
      this.toast.showSuccess("Glumac obrisan!");
      this.showDeletePopup = false;
      this.loadGlumci();
    });
  }

  closeDelete() { this.showDeletePopup = false; this.glumacToDelete = undefined; }
}
