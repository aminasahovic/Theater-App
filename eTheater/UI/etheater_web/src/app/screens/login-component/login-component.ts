import { CommonModule } from '@angular/common';
import { ChangeDetectorRef, Component, NgZone } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { finalize } from 'rxjs/operators';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-login-component',
  templateUrl: './login-component.html',
   styleUrls: ['./login-component.css'],
   standalone:false
})
export class LoginComponent {
  username = '';
  password = '';
  showError = false;
  errorMessage = '';
  isLoading = false;
  showPassword = false;
  currentYear = new Date().getFullYear();

  constructor(
    private authService: AuthService,
    private router: Router,
    private cdr: ChangeDetectorRef,
    private zone: NgZone
  ) {}

  login() {
    if (this.isLoading) return;
    this.isLoading = true;
    this.showError = false;

    this.authService
      .login(this.username, this.password)
      .pipe(
        finalize(() => {
          this.isLoading = false;
          this.zone.run(() => this.cdr.detectChanges());
        })
      )
      .subscribe({
        next: () => this.router.navigate(['/predstave']),
        error: (err: unknown) => {
          this.errorMessage =
            err instanceof Error && err.message
              ? err.message
              : 'Neuspješna prijava. Pogrešno korisničko ime ili lozinka.';
          this.showError = true;
          this.zone.run(() => this.cdr.detectChanges());
        }
      });
  }
}
