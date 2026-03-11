import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
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

  constructor(private authService: AuthService, private router: Router) {}

  async login() {
    if (this.isLoading) return;
    this.isLoading = true;
    this.showError = false;

    try {
      await this.authService.login(this.username, this.password);
      this.router.navigate(['/predstave']);
    } catch (err: any) {
      this.errorMessage = err.message || 'Pogrešno korisničko ime ili lozinka!';
      this.showError = true;
    } finally {
      this.isLoading = false;
    }
  }
}
