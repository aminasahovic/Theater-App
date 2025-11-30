import { Component } from '@angular/core';
import { AuthService } from '../../../services/auth.service';
import { Router, RouterModule } from '@angular/router';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-master-layout-component',
  templateUrl: './master-layout-component.html',
  styleUrls: ['./master-layout-component.css'],
  standalone: false
})
export class MasterLayoutComponent {
  osobljeExpanded = false;
  repertoarExpanded = false;
  komentariExpanded = false;

  constructor(private authService: AuthService, private router: Router) { }

  logout() {
    const potvrda = confirm('Da li ste sigurni da se želite odjaviti?');
    if (potvrda) {
      this.authService.logout();
      this.router.navigate(['/']);
    }
  }

  navigate(route: string) {
    this.router.navigate([route]);
  }
}
