import { Component } from '@angular/core';
import { AuthService } from '../../../services/auth.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-master-layout-component',
  templateUrl: './master-layout-component.html',
  styleUrls: ['./master-layout-component.css'],
  standalone:false
})
export class MasterLayoutComponent {
  osobljeExpanded = false;
  repertoarExpanded = false;
  komentariExpanded = false;

  showLogoutPopup = false;
  activeRoute = '';

  constructor(private authService: AuthService, private router: Router) {
    this.activeRoute = this.router.url;
    this.router.events.subscribe(() => {
      this.activeRoute = this.router.url;
    });
  }

  navigate(route: string) {
    this.router.navigate([route]);
    this.activeRoute = route;
  }

  confirmLogout() {
    this.authService.logout();
    this.router.navigate(['/']);
  }
}
