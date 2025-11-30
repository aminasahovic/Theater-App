import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { ApiKonstante } from '../api-konstante';
import { lastValueFrom } from 'rxjs';

interface LoginResponse {
  id: number;
  ime: string;
  prezime: string;
  username: string;
  tipKorisnikaId: number;
  email: string;
  brojTelefona: string;
  isActive: boolean;
  slikaProfila: string | null;
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  korisnikId?: number;
  username?: string;
  password?: string;

  constructor(private http: HttpClient) {}

  async login(user: string, pass: string): Promise<void> {
    const url = `${ApiKonstante.baseUrl}/Korisnik/login?username=${user}&password=${pass}`;

    const response = await lastValueFrom(this.http.post<LoginResponse>(url, {}, {
      headers: { 'accept': 'text/plain' }
    }));

    if (response.tipKorisnikaId !== 4) {
      throw new Error("Pristup dozvoljen samo administratorima (tip 4).");
    }

    this.korisnikId = response.id;
    this.username = user;
    this.password = pass;
    console.log(this.username)
    console.log(this.password)
  }

  logout() {
    this.korisnikId = undefined;
    this.username = undefined;
    this.password = undefined;
  }
}
