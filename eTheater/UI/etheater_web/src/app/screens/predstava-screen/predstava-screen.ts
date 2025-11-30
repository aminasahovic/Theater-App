import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { forkJoin } from 'rxjs';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { PredstaveService } from '../../services/predstava.service ';

@Component({
  selector: 'app-predstava-screen',
  templateUrl: './predstava-screen.html',
  styleUrls: ['./predstava-screen.css'],
  standalone: false
})
export class PredstavaScreen implements OnInit {
  showNotification = false;
  notificationMessage = '';
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

  page = 1;
  pageSize = 12;
  total = 0;
  get totalPages() { return Math.ceil(this.total / this.pageSize); }

  showFilter = false;
  showDodajPopup = false;
  searchTimeout: any;

  dodajForm: FormGroup;
  plakatBase64 = '';

  constructor(
    private api: PredstaveService,
    private cd: ChangeDetectorRef,
    private fb: FormBuilder
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
    this.loadFilterDataAndPredstave();
  }

  generateGodine() {
    const year = new Date().getFullYear();
    this.godine = Array.from({ length: 50 }, (_, i) => year - i);
  }

  loadFilterDataAndPredstave() {
    forkJoin({
      zanrovi: this.api.getZanrovi(),
      reziseri: this.api.getReziseri()
    }).subscribe({
      next: ({ zanrovi, reziseri }) => {
        this.zanrovi = Array.isArray(zanrovi) ? zanrovi : [];
        this.reziseri = Array.isArray(reziseri) ? reziseri : [];
        this.loadPredstave();
      },
      error: () => {
        this.zanrovi = [];
        this.reziseri = [];
        this.loadPredstave();
      }
    });
  }


  loadPredstave() {
    this.loading = true;
    const filter = {
      naziv: this.naziv,
      zanrId: this.zanrId,
      reziserId: this.reziserId,
      godina: this.godina,
      isActive: this.isActive,
      page: this.page,
      pageSize: this.pageSize
    };

    this.api.getPredstave(filter).subscribe({
      next: res => {
        this.predstave = Array.isArray(res.resultList) ? res.resultList : [];
        this.total = typeof res.count === 'number' ? res.count : 0;
        this.loading = false;
        this.cd.detectChanges();
      },
      error: () => {
        console.error("Greška pri učitavanju predstava");
        this.predstave = [];
        this.total = 0;
        this.loading = false;
        this.cd.detectChanges();
      }
    });
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
      next: () => {
        this.showDodajPopup = false;
        this.loadPredstave();
        this.showSuccess('Predstava uspješno dodana!');
      },
      error: (err) => {
        console.error(err);
        this.showDodajPopup = false;
        this.loadPredstave();
        this.showSuccess('Predstava uspješno dodana!');
      }
    });
  }


  deletePredstava() {
    if (!this.predstavaToDelete) return;

    this.api.deletePredstavu(this.predstavaToDelete.id).subscribe({
      next: () => {
        this.showDeletePopup = false;
        this.loadPredstave();
        this.showSuccess('Predstava je obrisana!');
      },
      error: (err) => {
        console.error(err);
        this.showDeletePopup = false;
        this.showSuccess('Greška pri brisanju predstave!');
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
        this.loadPredstave();
        this.showSuccess("Predstava uspješno obrisana!");
      },
      error: (err) => {
        console.error(err);
        this.showDeletePopup = false;
        this.showSuccess("Greška pri brisanju predstave!");
      }
    });
  }


  showSuccess(message: string) {
    this.notificationMessage = message;
    this.showNotification = true;
    setTimeout(() => this.showNotification = false, 3000); 
  }

}
