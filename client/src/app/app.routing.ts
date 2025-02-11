import { NgModule } from '@angular/core';
import { CommonModule, } from '@angular/common';
import { BrowserModule  } from '@angular/platform-browser';
import { Routes, RouterModule } from '@angular/router';
import { RecordDetailComponent } from './record-detail/record-detail.component';

import { LoginComponent } from './login/login.component';
import { AdminLayoutComponent } from './layouts/admin-layout/admin-layout.component';

const routes: Routes =[
  { path: 'login', 
    component: LoginComponent 
  },
  { path: '', 
    redirectTo: 'login', 
    pathMatch: 'full' 
  },
  {
    path: '',
    component: AdminLayoutComponent,
    children: [
        {  path: '', loadChildren: () => import('./layouts/admin-layout/admin-layout.module').then(x => x.AdminLayoutModule) },
        { path: ':objectType/:recordId', component: RecordDetailComponent }
    ]
  },
  {
    path: '**',
    redirectTo: 'dashboard'
  }
];

@NgModule({
  imports: [
    CommonModule,
    BrowserModule,
    RouterModule.forRoot( routes, { useHash: true } )
  ],
  exports: [
  ],
})
export class AppRoutingModule { }
