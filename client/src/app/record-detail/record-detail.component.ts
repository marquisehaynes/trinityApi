import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { ApiService } from '../api.service';

@Component({
  selector: 'app-record-detail',
  template: `
    <div *ngIf="record">
      <h2>{{ record.name || 'Record Details' }}</h2>
      <pre>{{ record | json }}</pre>
    </div>
    <div *ngIf="loading">Loading...</div>
    <div *ngIf="error">{{ error }}</div>
  `,
  styles: [
    `
      div {
        margin: 20px;
      }
    `,
  ],
})
export class RecordDetailComponent implements OnInit {
  record: any = null;
  loading = false;
  error: string | null = null;

  constructor(
    private route: ActivatedRoute,
    private apiService: ApiService
  ) {}

  ngOnInit(): void {
    this.route.params.subscribe((params) => {
      const objectType = params['objectType'];
      const recordId = params['recordId'];
      this.fetchRecord(objectType, recordId);
    });
  }

  fetchRecord(objectType: string, recordId: string): void {
    this.loading = true;
    this.error = null;

    this.apiService.getRecord(objectType, recordId).subscribe({
      next: (data) => {
        this.record = data;
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Failed to fetch record';
        this.loading = false;
      },
    });
  }
}
