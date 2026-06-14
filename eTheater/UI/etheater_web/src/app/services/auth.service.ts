import { Injectable } from '@angular/core';
import { HttpClient, HttpErrorResponse, HttpParams } from '@angular/common/http';
import { ApiKonstante } from '../api-konstante';
import { Observable, of, throwError } from 'rxjs';
import { catchError, switchMap, timeout } from 'rxjs/operators';

const TIP_ADMINISTRATIVNO_OSOBLJE = 4;
const REQUEST_MS = 30000;

interface LoginResponse {
  id: number;
  ime: string;
  prezime: string;
  username: string;
  tipKorisnikaId?: number | null;
  email: string;
  brojTelefona: string;
  isActive: boolean;
  slikaProfila: string | null;
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  korisnikId?: number;
  username?: string;
  password?: string;

  constructor(private http: HttpClient) {
    const saved = localStorage.getItem('auth');
    if (saved) {
      const data = JSON.parse(saved);
      this.username = data.username;
      this.password = data.password;
      this.korisnikId = data.korisnikId;
    }
  }


  login(user: string, pass: string): Observable<void> {
    const params = new HttpParams().set('username', user).set('password', pass);
    const url = `${ApiKonstante.baseUrl}/Korisnik/login`;
    return this.http.post<LoginResponse | null>(url, {}, { params, observe: 'body' }).pipe(
      timeout(REQUEST_MS),
      catchError((e) => throwError(() => this.toLoginError(e))),
      switchMap((response) => {
        if (response == null) {
          return throwError(
            () =>
              new Error(
                'Neuspješna prijava. Korisnički račun ne postoji ili su korisničko ime i lozinka netačni.'
              )
          );
        }
        const tipId =
          response.tipKorisnikaId != null
            ? Number(response.tipKorisnikaId)
            : Number((response as { TipKorisnikaId?: number }).TipKorisnikaId);
        if (tipId !== TIP_ADMINISTRATIVNO_OSOBLJE) {
          return throwError(
            () =>
              new Error(
                'Nemate ovlaštenja za pristup ovom panelu. Samo korisnici s ulogom administrativnog osoblja mogu pristupiti.'
              )
          );
        }
        this.username = user;
        this.password = pass;
        this.korisnikId = response.id;
        localStorage.setItem(
          'auth',
          JSON.stringify({
            username: user,
            password: pass,
            korisnikId: response.id
          })
        );
        return of(void 0);
      })
    );
  }

  private toLoginError(e: unknown): Error {
    if (e && typeof e === 'object' && (e as { name?: string }).name === 'TimeoutError') {
      return new Error('Zahtjev je predugo čekao odgovor servera. Pokušajte ponovo.');
    }
    if (e instanceof HttpErrorResponse) {
      if (e.status === 0) {
        return new Error('Nema veze s serverom. Provjerite mrežu i je li API pokrenut.');
      }
      if (e.status === 401 || e.status === 403) {
        return new Error(
          'Neuspješna prijava. Korisnički račun ne postoji ili su korisničko ime i lozinka netačni.'
        );
      }
    }
    return new Error('Dogodila se greška pri prijavi. Pokušajte ponovo.');
  }

  logout() {
    this.username = undefined;
    this.password = undefined;
    this.korisnikId = undefined;
    localStorage.removeItem('auth');
  }
}