import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';

import { App } from './app';
import { PredstavaScreen } from './screens/predstava-screen/predstava-screen';
import { LoginComponent } from './screens/login-component/login-component';
import { MasterLayoutComponent } from './screens/shared/master-layout-component/master-layout-component';
import { AppRoutingModule } from './app.routes';

@NgModule({
  declarations: [
    App,
    PredstavaScreen,
    LoginComponent,
    MasterLayoutComponent
  ],
  imports: [
    BrowserModule,
    FormsModule,
    HttpClientModule,
    AppRoutingModule,
    ReactiveFormsModule
  ],
  providers: [],
  bootstrap: [App]
})
export class AppModule { }
