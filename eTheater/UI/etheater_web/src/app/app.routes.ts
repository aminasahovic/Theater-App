import { RouterModule, Routes } from '@angular/router';
import { LoginComponent } from './screens/login-component/login-component';
import { PredstavaScreen } from './screens/predstava-screen/predstava-screen';
import { MasterLayoutComponent } from './screens/shared/master-layout-component/master-layout-component';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';

export const routes: Routes = [
  { path: 'login', component: LoginComponent },
  { path: '', component: LoginComponent },
  {
    path: '',
    component: MasterLayoutComponent,
    children: [
      { path: 'predstave', component: PredstavaScreen },
    ]
  }

];
@NgModule({
  imports: [RouterModule.forRoot(routes), FormsModule
  ],
  exports: [RouterModule]
})
export class AppRoutingModule { }