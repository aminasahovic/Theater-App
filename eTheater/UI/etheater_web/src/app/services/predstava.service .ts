import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, map } from 'rxjs';
import { ApiKonstante } from '../api-konstante';
import { AuthService } from './auth.service';

@Injectable({ providedIn: 'root' })
export class PredstaveService {
  private baseUrl = `${ApiKonstante.baseUrl}/Predstava`;

  constructor(private http: HttpClient, private auth: AuthService) { }

  private authHeader() {
    if (!this.auth.username || !this.auth.password) return {};
    const token = btoa(`${this.auth.username}:${this.auth.password}`);
    return { headers: { "Authorization": `Basic ${token}` } };
  }

  getPredstave(filter: any): Observable<any> {
    let params = new HttpParams()
      .set('page', filter.page)
      .set('pageSize', filter.pageSize);

    if (filter.naziv) params = params.set('naziv', filter.naziv);
    if (filter.zanrId) params = params.set('zanrId', filter.zanrId);
    if (filter.reziserId) params = params.set('reziserId', filter.reziserId);
    if (filter.godina) params = params.set('godina', filter.godina);
    if (filter.isActive !== null && filter.isActive !== undefined)
      params = params.set('isActive', filter.isActive.toString());

    return this.http.get<any>(`${this.baseUrl}`, { params, ...this.authHeader() });
  }

  getZanrovi(): Observable<any[]> {
    return this.http.get<any>(`${ApiKonstante.baseUrl}/Zanr`, this.authHeader())
      .pipe(map(res => res.resultList || []));
  }

  getReziseri(): Observable<any[]> {
    return this.http.get<any>(`${ApiKonstante.baseUrl}/Reziser`, this.authHeader())
      .pipe(map(res => res.resultList || []));
  }

  dodajPredstavu(predstava: any): Observable<any> {
    return this.http.post<any>(`${this.baseUrl}`, predstava, this.authHeader());
  }

  deletePredstavu(id: number): Observable<any> {
    return this.http.delete(`${this.baseUrl}/${id}`, this.authHeader());
  }
  getPredstavaById(id: number): Observable<any> {
    return this.http.get<any>(`${this.baseUrl}/${id}`, this.authHeader());
  }

  updatePredstava(predstava: any): Observable<any> {
    return this.http.put<any>(`${this.baseUrl}/${predstava.id}`, predstava, this.authHeader());
  }

 getGlumciZaPredstavu(predstavaId: number) {
  return this.http.get<any[]>(`${ApiKonstante.baseUrl}/GlumacPredstava/predstava/${predstavaId}/glumci`, this.authHeader());
}


}
