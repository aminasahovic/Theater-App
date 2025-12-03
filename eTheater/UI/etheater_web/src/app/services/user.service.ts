import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, map } from 'rxjs';
import { ApiKonstante } from '../api-konstante';
import { AuthService } from './auth.service';

export interface Korisnik {
  id: number;
  ime: string;
  prezime: string;
  username: string;
  brojTelefona: string;
  tipKorisnikaId: number;
  email?: string;
  isActive?: boolean | null;
  slikaProfila?: string | null; 
}

export interface TipKorisnika {
  id: number;
  naziv: string;
}

@Injectable({ providedIn: 'root' })
export class UserService {
  private baseUrl = `${ApiKonstante.baseUrl}/Korisnik`;
  private tipUrl = `${ApiKonstante.baseUrl}/TipKorisnika`;

  constructor(private http: HttpClient, private auth: AuthService) {}

  private authHeader() {
    if (!this.auth.username || !this.auth.password) return {};
    const token = btoa(`${this.auth.username}:${this.auth.password}`);
    return { headers: { "Authorization": `Basic ${token}` } };
  }

 getKorisnici(
  ime?: string,
  prezime?: string,
  username?: string,
  tipKorisnikaId?: number,
  isActive?: boolean,
  page = 1,
  pageSize = 10
): Observable<{ data: Korisnik[], total: number }> {
  let params = new HttpParams()
    .set('Page', page)
    .set('PageSize', pageSize);

  if (ime) params = params.set('ImeGTE', ime);
  if (prezime) params = params.set('PrezimeGTE', prezime);
  if (username) params = params.set('KorisnickoIme', username);
  if (tipKorisnikaId) params = params.set('IsTipKorisnika', tipKorisnikaId);
  if (isActive !== undefined && isActive !== null) 
    params = params.set('IsActive', isActive);

  return this.http.get<any>(this.baseUrl, { params, ...this.authHeader() })
    .pipe(
      map(res => ({
        data: res.resultList || [],
        total: res.count || 0
      }))
    );
}

  getTipovi(): Observable<TipKorisnika[]> {
    return this.http.get<any>(this.tipUrl, this.authHeader())
      .pipe(map(res => res.resultList || []));
  }

  deleteKorisnik(id: number) {
    return this.http.delete(`${this.baseUrl}/${id}`, this.authHeader());
  }

  dodajKorisnika(korisnik: Korisnik) {
    return this.http.post(this.baseUrl, korisnik, this.authHeader());
  }

  updateKorisnika(korisnik: Korisnik) {
    return this.http.put(`${this.baseUrl}/${korisnik.id}`, korisnik, this.authHeader());
  }

  getKorisnikById(id: number) {
    return this.http.get<Korisnik>(`${this.baseUrl}/${id}`, this.authHeader());
  }
}
