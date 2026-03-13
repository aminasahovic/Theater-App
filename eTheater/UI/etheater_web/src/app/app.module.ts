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
import { NovostiScreenComponent } from './screens/novosti-screen-component/novosti-screen-component';
import { Toast } from './screens/shared/toast/toast';
import { GlumciScreen } from './screens/glumci-screen/glumci-screen';
import { ReziseriScreen } from './screens/reziseri-screen/reziseri-screen';
import { IzvedbaScreen } from './screens/izvedba-screen/izvedba-screen';
import { RepertoarScreen } from './screens/repertoar-screen/repertoar-screen';
import { KomentariPredstaveScreen } from './screens/komentari-predstave-screen/komentari-predstave-screen';
import { KomentariNovostiScreen } from './screens/komentari-novosti-screen/komentari-novosti-screen';
import { ChatWidgetComponent } from './screens/shared/chat-widget/chat-widget';

@NgModule({
  declarations: [
    App,
    PredstavaScreen,
    LoginComponent,
    MasterLayoutComponent,
    PredstavaDetails,
    UserListComponent,
    NovostiScreenComponent,
    Toast,
    GlumciScreen,
    ReziseriScreen,
    IzvedbaScreen,
    RepertoarScreen,
    KomentariPredstaveScreen,
    KomentariNovostiScreen,
    ChatWidgetComponent
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
