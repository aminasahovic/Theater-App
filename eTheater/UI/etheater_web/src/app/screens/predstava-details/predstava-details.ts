import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { PredstaveService } from '../../services/predstava.service ';
import { forkJoin } from 'rxjs';

@Component({
  selector: 'app-predstava-details',
  templateUrl: './predstava-details.html',
  styleUrls: ['./predstava-details.css'],
  standalone:false
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
    private router: Router
  ) {}

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

  this.predstavaId = Number(this.route.snapshot.paramMap.get('id'));
  this.loadPredstava();
}

loadPredstava() {
  this.loading = true;

  this.api.getPredstavaById(this.predstavaId).subscribe({
    next: (p) => {
      this.predstava = p;
      this.slikaBase64 = p.plakat;
      this.slikaPreview = p.plakat ? 'data:image/png;base64,' + p.plakat : '';

      this.form.patchValue({
        naziv: p.naziv,
        opis: p.opis,
        trajanje: p.trajanje,
        godina: p.godina,
        zanrId: p.zanrId,
        reziserId: p.reziserId,
        isActive: p.isActive
      });

      this.api.getZanrovi().subscribe(z => this.zanrovi = z || []);
      this.api.getReziseri().subscribe(r => this.reziseri = r || []);
      this.api.getGlumciZaPredstavu(this.predstavaId).subscribe(g => this.glumci = g || []);

      this.loading = false; 
    },
    error: () => this.loading = false
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
      next: () => { this.editing = false; alert('Podaci uspješno ažurirani'); },
      error: () => alert('Greška pri ažuriranju')
    });
  }

  delete() {
    this.api.deletePredstavu(this.predstavaId).subscribe({
      next: () => this.router.navigate(['/predstave'])
    });
  }
}
