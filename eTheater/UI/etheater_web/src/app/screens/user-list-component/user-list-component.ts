import { ChangeDetectorRef, Component, HostListener, OnDestroy, OnInit } from '@angular/core';
import { Subject, switchMap, takeUntil, tap } from 'rxjs';
import { FormBuilder, FormGroup } from '@angular/forms';
import { Router } from '@angular/router';
import { Korisnik, TipKorisnika, UserService } from '../../services/user.service';
import { ToastService } from '../../services/toast.service';

@Component({
  selector: 'app-user-list-component',
  templateUrl: './user-list-component.html',
  styleUrls: ['./user-list-component.css'],
  standalone: false
})
export class UserListComponent implements OnInit, OnDestroy {

  korisnici: Korisnik[] = [];
  tipovi: TipKorisnika[] = [];
  tipMap: Record<number, string> = {};
  loading = false;

  page = 1;
  pageSize = 15;
  totalCount = 0;
  get totalPages() { return Math.ceil(this.totalCount / this.pageSize); }

  ime = '';
  prezime = '';
  username = '';
  tipId: number | null = null;
  isActive: boolean | null = null;

  imeTimeout: any;
  prezimeTimeout: any;
  usernameTimeout: any;

  private readonly reload$ = new Subject<void>();
  private readonly destroy$ = new Subject<void>();

  showFilterPopup = false;


  showEditPopup = false;
  editMode = false;
  editForm!: FormGroup;
  currentEditUserId?: number;
  slikaProfilaBase64?: string;

  constructor(
    private userService: UserService,
    private cd: ChangeDetectorRef,
    private fb: FormBuilder,
    private router: Router,
    private toast: ToastService
  ) {
    this.editForm = this.fb.group({
      ime: [''],
      prezime: [''],
      username: [''],
      password: [''],
      passwordPotvrda: [''],
      email: [''],
      brojTelefona: [''],
      tipKorisnikaId: [null],
      isActive: [true]
    });
  }

  ngOnInit(): void {
    this.loadTipovi();
    this.setupUserPipeline();
    this.reload$.next();
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  @HostListener('document:click', ['$event'])
  onDocumentClick(event: MouseEvent) {
    const target = event.target as HTMLElement;
    if (!target.closest('.filter-card')) {
      this.showFilterPopup = false;
    }
  }

  private loadTipovi(): void {
    this.userService.getTipovi()
      .pipe(takeUntil(this.destroy$))
      .subscribe({
        next: tipovi => {
          this.tipovi = Array.isArray(tipovi) ? tipovi : [];
          this.tipMap = this.tipovi.reduce((acc, t) => ({ ...acc, [t.id]: t.naziv }), {});
        },
        error: () => {
          this.tipovi = [];
          this.tipMap = {};
        }
      });
  }

  private setupUserPipeline(): void {
    this.reload$.pipe(
      tap(() => {
        this.loading = true;
        this.cd.detectChanges();
      }),
      switchMap(() => {
        const ime = this.ime || undefined;
        const prezime = this.prezime || undefined;
        const username = this.username || undefined;
        const tipId = this.tipId ?? undefined;
        const isActive = (this.isActive !== null && this.isActive !== undefined)
          ? this.isActive : undefined;

        return this.userService.getKorisnici(
          ime, prezime, username, tipId as any, isActive as any,
          this.page, this.pageSize
        );
      }),
      takeUntil(this.destroy$)
    ).subscribe({
      next: res => {
        this.korisnici = Array.isArray(res.data) ? res.data : [];
        this.totalCount = typeof res.total === 'number' ? res.total : 0;
        this.loading = false;
        this.cd.detectChanges();
      },
      error: () => {
        this.korisnici = [];
        this.totalCount = 0;
        this.loading = false;
        this.cd.detectChanges();
      }
    });
  }

  onImeChange(val: string) {
    this.ime = val;
    clearTimeout(this.imeTimeout);
    this.imeTimeout = setTimeout(() => this.applyFilters(), 300);
  }

  onPrezimeChange(val: string) {
    this.prezime = val;
    clearTimeout(this.prezimeTimeout);
    this.prezimeTimeout = setTimeout(() => this.applyFilters(), 300);
  }

  onUsernameChange(val: string) {
    this.username = val;
    clearTimeout(this.usernameTimeout);
    this.usernameTimeout = setTimeout(() => this.applyFilters(), 300);
  }

  loadUsers(): void {
    this.reload$.next();
  }

  applyFilters() {
    this.page = 1;
    this.loadUsers();
  }

  resetFilters() {
    this.ime = '';
    this.prezime = '';
    this.username = '';
    this.tipId = null;
    this.isActive = null;
    this.applyFilters();
  }

  prevPage() {
    if (this.page > 1) {
      this.page--;
      this.loadUsers();
    }
  }

  nextPage() {
    if (this.page < this.totalPages) {
      this.page++;
      this.loadUsers();
    }
  }

  openDetails(id: number) {
    this.router.navigate(['/users', id]);
  }

  editUser(user: Korisnik) {
    this.openEditPopup(user);
  }



  openEditPopup(user?: Korisnik) {
    this.editMode = !!user;
    this.showEditPopup = true;

    if (user) {
      this.currentEditUserId = user.id;
      this.editForm.patchValue({
        ime: user.ime,
        prezime: user.prezime,
        username: user.username,
        password: '',
        passwordPotvrda: '',
        email: user.email,
        brojTelefona: user.brojTelefona,
        tipKorisnikaId: user.tipKorisnikaId,
        isActive: user.isActive
      });
      this.slikaProfilaBase64 = user.slikaProfila || undefined;
    } else {
      this.currentEditUserId = undefined;
      this.editForm.reset({ isActive: true });
      this.slikaProfilaBase64 = undefined;
    }
  }

  closeEditPopup() {
    this.showEditPopup = false;
    this.editForm.reset({ isActive: true });
    this.slikaProfilaBase64 = undefined;
  }

  onFileChange(event: any) {
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = () => this.slikaProfilaBase64 = reader.result as string;
      reader.readAsDataURL(file);
    }
  }

  submitEdit() {
    if (this.editForm.invalid) return alert("Popunite sva obavezna polja!");
    const val = this.editForm.value;

    if (val.password !== val.passwordPotvrda)
      return alert("Password i potvrda se ne podudaraju!");

    const korisnik: any & { password?: string, passwordPotvrda?: string, slikaProfila?: string } = {
      ime: val.ime,
      prezime: val.prezime,
      username: val.username,
      password: val.password || undefined,
      passwordPotvrda: val.passwordPotvrda || undefined,
      email: val.email,
      brojTelefona: val.brojTelefona,
      tipKorisnikaId: val.tipKorisnikaId,
      isActive: val.isActive,
      slikaProfila: this.slikaProfilaBase64
    };

    if (this.editMode && this.currentEditUserId) {
      korisnik.id = this.currentEditUserId;
      this.userService.updateKorisnika(korisnik).subscribe(() => {
        this.toast.showSuccess("Korisnik ažuriran!");
        this.closeEditPopup();
        this.loadUsers();
      });
    } else {
      this.userService.dodajKorisnika(korisnik).subscribe(() => {
        this.toast.showSuccess("Korisnik dodan!");
        this.closeEditPopup();
        this.loadUsers();
      });
    }
  }
  deleteUser(user: Korisnik) {
    this.userToDelete = user;
    this.showDeletePopup = true;
  }

  showDeletePopup = false;
  userToDelete: any = null;
  confirmDeleteUser() {
    if (!this.userToDelete) return;

    this.userService.deleteKorisnik(this.userToDelete.id).subscribe({
      next: () => {
        this.showDeletePopup = false;
        this.toast.showSuccess("Korisnik uspješno obrisan!");
        this.loadUsers();
      },
      error: () => {
        this.showDeletePopup = false;
        this.toast.showError("Greška pri brisanju korisnika!");
      }
    });
  }

  getTipNaziv(id: number) { return this.tipMap[id] || '-'; }
  getStatus(isActive?: boolean | null) { return isActive ? 'Aktivan' : 'Neaktivan'; }
}
