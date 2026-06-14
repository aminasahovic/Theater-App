import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { ApiKonstante } from '../api-konstante';
import { AuthService } from './auth.service';

@Injectable({ providedIn: 'root' })
export class IzvedbaService {

  private baseUrl = `${ApiKonstante.baseUrl}/Izvedba`;
  private addUrl = `${ApiKonstante.baseUrl}/add`;
  private baseUrlGetAll = `${ApiKonstante.baseUrl}/getall`;

  constructor(private http: HttpClient, private auth: AuthService) { }

  private authHeader() {
    const token = btoa(`${this.auth.username}:${this.auth.password}`);
    return { headers: { "Authorization": `Basic ${token}` } };
  }

  getIzvedbe(filter: any): Observable<any> {
    let params = new HttpParams()
      .set("Page", filter.page)
      .set("PageSize", filter.pageSize);

    if (filter.salaId) params = params.set("SalaId", filter.salaId);
    if (filter.search) params = params.set("NazivPredstave", filter.search);
    if (filter.datumIzvodjenja) params = params.set("DatumIzvodjenja", filter.datumIzvodjenja);

    return this.http.get<any>(this.baseUrlGetAll, { params, ...this.authHeader() });
  }
  updateIzvedba(id: number, data: any): Observable<any> {
    return this.http.put(
      `${this.baseUrl}/${id}`,
      data,
      this.authHeader()
    );
  }


  dodajIzvedbu(data: any): Observable<any> {
    return this.http.post(this.addUrl, data, this.authHeader());
  }

  deleteIzvedba(id: number): Observable<any> {
    return this.http.delete(`${this.baseUrl}/${id}`, this.authHeader());
  }
  getIzvedbePeriod(pocetak: string, kraj: string) {
  const params = new HttpParams()
    .set('DatumOd', pocetak)
    .set('DatumDo', kraj);
  return this.http.get<any[]>(`${ApiKonstante.baseUrl}/Izvedba/period`, { params, ...this.authHeader() });
}

}
