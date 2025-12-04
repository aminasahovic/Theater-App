import { Injectable } from '@angular/core';
import { Subject } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class ToastService {
  toast$ = new Subject<{ message: string, type: 'success' | 'error' }>();

  showSuccess(message: string) {
    this.toast$.next({ message, type: 'success' });
  }

  showError(message: string) {
    this.toast$.next({ message, type: 'error' });
  }
}
