import { ChangeDetectionStrategy, ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { ToastService } from '../../../services/toast.service';

@Component({
  selector: 'app-toast',
  templateUrl: './toast.html',
  styleUrls: ['./toast.css'],
  standalone:false,
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class Toast implements OnInit {

  show = false;
  message = '';
  type: 'success' | 'error' = 'success';

  constructor(
    private toastService: ToastService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit() {
    this.toastService.toast$.subscribe(toast => {

      // Sve promjene guramo u sljedeći ciklus
      setTimeout(() => {
        this.message = toast.message;
        this.type = toast.type;
        this.show = true;
        this.cdr.markForCheck();

        // Sakrij nakon 3 sekunde
        setTimeout(() => {
          this.show = false;
          this.cdr.markForCheck();
        }, 3000);

      });
    });
  }
}
