import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';
import { AgGridModule } from 'ag-grid-angular';

import { App } from './app';
import { PredstavaScreen } from './screens/predstava-screen/predstava-screen';
import { LoginComponent } from './screens/login-component/login-component';
import { MasterLayoutComponent } from './screens/shared/master-layout-component/master-layout-component';
import { AppRoutingModule } from './app.routes';
import { PredstavaDetails } from './screens/predstava-details/predstava-details';
import { UserListComponent } from './screens/user-list-component/user-list-component';

@NgModule({
  declarations: [
    App,
    PredstavaScreen,
    LoginComponent,
    MasterLayoutComponent,
    PredstavaDetails,
    UserListComponent  
  ],
  imports: [
    BrowserModule,
    FormsModule,
    ReactiveFormsModule,
    HttpClientModule,
    AppRoutingModule,
    AgGridModule
  ],
  providers: [],
  bootstrap: [App]
})
export class AppModule { }
