import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent {
  username: string = '';
  password: string = '';
  email: string = '';
  phone: string = '';

  login() {
    // For now, let's just log the credentials to the console.
    console.log('Username:', this.username);
    console.log('Password:', this.password);
  }
}