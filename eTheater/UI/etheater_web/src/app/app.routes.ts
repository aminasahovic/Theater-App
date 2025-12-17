import { RouterModule, Routes } from '@angular/router';
import { LoginComponent } from './screens/login-component/login-component';
import { PredstavaScreen } from './screens/predstava-screen/predstava-screen';
import { MasterLayoutComponent } from './screens/shared/master-layout-component/master-layout-component';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { PredstavaDetails } from './screens/predstava-details/predstava-details';
import { UserListComponent } from './screens/user-list-component/user-list-component';
import { NovostiScreenComponent } from './screens/novosti-screen-component/novosti-screen-component';
import { GlumciScreen } from './screens/glumci-screen/glumci-screen';
import { ReziseriScreen } from './screens/reziseri-screen/reziseri-screen';
import { IzvedbaScreen } from './screens/izvedba-screen/izvedba-screen';

export const routes: Routes = [
  { path: 'login', component: LoginComponent },
  { path: '', component: LoginComponent },
  {
    path: '',
    component: MasterLayoutComponent,
    children: [
      { path: 'predstave', component: PredstavaScreen },
      { path: 'predstave/:id', component: PredstavaDetails },
      { path: 'korisnici', component: UserListComponent },
      { path: 'novosti', component: NovostiScreenComponent },
      { path: 'glumci', component: GlumciScreen },
      { path: 'reziseri', component: ReziseriScreen },
      { path: 'izvedbe', component: IzvedbaScreen }


    ]
  }

];
@NgModule({
  imports: [RouterModule.forRoot(routes), FormsModule
  ],
  exports: [RouterModule]
})
export class AppRoutingModule { }