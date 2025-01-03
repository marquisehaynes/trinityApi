import { Component, OnInit } from '@angular/core';

declare const $: any;
declare interface RouteInfo {
    path: string;
    title: string;
    icon: string;
    class: string;
}

/*
export const ROUTES: RouteInfo[] = [
  { path: '/dashboard2', title: 'Dashboard',  icon: 'pe-7s-graph', class: '' },
    { path: '/dashboard2', title: 'Dashboard2',  icon: 'pe-7s-graph', class: '' },
    { path: '/user', title: 'User Profile',  icon:'pe-7s-user', class: '' },
    { path: '/table', title: 'Table List',  icon:'pe-7s-note2', class: '' },
    { path: '/typography', title: 'Typography',  icon:'pe-7s-news-paper', class: '' },
    { path: '/icons', title: 'Icons',  icon:'pe-7s-science', class: '' },
    { path: '/maps', title: 'Maps',  icon:'pe-7s-map-marker', class: '' },
    { path: '/notifications', title: 'Notifications',  icon:'pe-7s-bell', class: '' },
    { path: '/upgrade', title: 'Upgrade to PRO',  icon:'pe-7s-rocket', class: 'active-pro' },
]; 
*/

export const ROUTES: RouteInfo[] = [
    { path: '/dashboard', title: 'Dashboard',  icon: 'pe-7s-graph', class: '' },
    { path: '/courses', title: 'Courses',  icon: 'pe-7s-graph', class: '' },
    { path: '/students', title: 'Students',  icon: 'pe-7s-graph', class: '' },
    { path: '/assignmentgroups', title: 'Assignment Groups',  icon:'pe-7s-user', class: '' },
    { path: '/assignments', title: 'Assignments',  icon:'pe-7s-note2', class: '' },
    { path: '/submissions', title: 'Assignment Submissions',  icon:'pe-7s-news-paper', class: '' },
    { path: '/transcripts', title: 'Transcripts',  icon:'pe-7s-science', class: '' },
    { path: '/timesheets', title: 'Timesheets',  icon:'pe-7s-map-marker', class: '' },
    { path: '/reports', title: 'Reports',  icon: 'pe-7s-graph', class: '' }
];

@Component({
  selector: 'app-sidebar',
  templateUrl: './sidebar.component.html'
})
export class SidebarComponent implements OnInit {
  menuItems: any[];

  constructor() { }

  ngOnInit() {
    this.menuItems = ROUTES.filter(menuItem => menuItem);
  }
  isMobileMenu() {
      if ($(window).width() > 991) {
          return false;
      }
      return true;
  };
}
