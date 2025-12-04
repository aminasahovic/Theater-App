import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { PredstaveService } from '../../services/predstava.service ';
import { forkJoin } from 'rxjs';
import { ToastService } from '../../services/toast.service';

@Component({
  selector: 'app-predstava-details',
  templateUrl: './predstava-details.html',
  styleUrls: ['./predstava-details.css'],
  standalone: false
})
export class PredstavaDetails implements OnInit {
  loading = true;
  form!: FormGroup;
  editing = false;

  predstavaId!: number;
  predstava: any;
  zanrovi: any[] = [];
  reziseri: any[] = [];
  glumci: any[] = [];

  slikaBase64 = '';
  slikaPreview = '';

  showDeletePopup = false;

  constructor(
    private route: ActivatedRoute,
    private api: PredstaveService,
    private fb: FormBuilder,
    private router: Router,
    private toast: ToastService,
    private cd: ChangeDetectorRef

  ) { }

  ngOnInit(): void {
    this.form = this.fb.group({
      naziv: [''],
      opis: [''],
      trajanje: [0],
      godina: [0],
      zanrId: [null],
      reziserId: [null],
      isActive: [false]
    });

    this.route.paramMap.subscribe(params => {
      this.predstavaId = Number(params.get('id'));
      this.loadPredstava();
    });
  }

  loadPredstava() {
    this.loading = true;

    forkJoin({
      predstava: this.api.getPredstavaById(this.predstavaId),
      zanrovi: this.api.getZanrovi(),
      reziseri: this.api.getReziseri(),
      glumci: this.api.getGlumciZaPredstavu(this.predstavaId)
    }).subscribe({
      next: ({ predstava, zanrovi, reziseri, glumci }) => {
        this.predstava = predstava;
        this.slikaBase64 = predstava.plakat;
        this.slikaPreview = predstava.plakat ? 'data:image/png;base64,' + predstava.plakat : '';

        this.form.patchValue({
          naziv: predstava.naziv,
          opis: predstava.opis,
          trajanje: predstava.trajanje,
          godina: predstava.godina,
          zanrId: predstava.zanrId,
          reziserId: predstava.reziserId,
          isActive: predstava.isActive
        });

        this.zanrovi = zanrovi || [];
        this.reziseri = reziseri || [];
        this.glumci = glumci || [];

        this.loading = false;
        this.cd.detectChanges();
      },
      error: (err) => {
        console.error('Greška pri učitavanju detalja predstave', err);
        this.loading = false;
        this.cd.detectChanges();
      }
    });
  }

  loadDropdownsAndGlumce() {

    forkJoin({
      zanrovi: this.api.getZanrovi(),
      reziseri: this.api.getReziseri(),
      glumci: this.api.getGlumciZaPredstavu(this.predstavaId)
    }).subscribe({
      next: (res) => {
        this.zanrovi = res.zanrovi || [];
        this.reziseri = res.reziseri || [];
        this.glumci = res.glumci || [];
        this.loading = false;
      },
      error: () => {
        this.loading = false;
        console.error('Greška pri učitavanju dropdowna ili glumaca');
      }
    });
  }

  initForm() {
    this.form = this.fb.group({
      naziv: [this.predstava.naziv, Validators.required],
      opis: [this.predstava.opis, Validators.required],
      trajanje: [this.predstava.trajanje, Validators.required],
      godina: [this.predstava.godina, Validators.required],
      zanrId: [this.predstava.zanrId, Validators.required],
      reziserId: [this.predstava.reziserId, Validators.required],
      isActive: [this.predstava.isActive]
    });
  }

  toggleEdit() { this.editing = !this.editing; }

  onSlikaSelected(event: any) {
    const file = event.target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => {
      const base64 = (reader.result as string).split(',')[1];
      this.slikaBase64 = base64;
      this.slikaPreview = 'data:image/png;base64,' + base64;
    };
    reader.readAsDataURL(file);
  }

  save() {
    if (this.form.invalid) return;
    const updated = { id: this.predstavaId, ...this.form.value, plakat: this.slikaBase64 };
    this.api.updatePredstava(updated).subscribe({
      next: () => {
        this.editing = false; this.toast.showSuccess('Podaci uspješno ažurirani');
      },
      error: () => this.toast.showError('Greška pri ažuriranju')

    });
  }

  delete() {
    this.api.deletePredstavu(this.predstavaId).subscribe({
      next: () => {
        this.toast.showSuccess('Predstava uspješno obrisana');
        this.router.navigate(['/predstave']);
      },
      error: () => {
        this.toast.showError('Greška pri brisanju predstave');
      }
    });
  }
}
