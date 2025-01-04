import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class ApiService {
  private baseUrl = 'https://api.example.com'; // Replace with your API URL

  constructor(private http: HttpClient) {}

  getRecord(objectType: string, recordId: string): Observable<any> {
    return this.http.get(`${this.baseUrl}/${objectType}/${recordId}`);
  }
}