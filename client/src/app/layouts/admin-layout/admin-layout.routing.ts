import { Routes } from '@angular/router';

import { HomeComponent } from '../../home/home.component';
import { UserComponent } from '../../user/user.component';
import { CoursesComponent } from '../../courses/courses.component';
import { TablesComponent } from '../../tables/tables.component';
import { TypographyComponent } from '../../typography/typography.component';
import { IconsComponent } from '../../icons/icons.component';
import { NotificationsComponent } from '../../notifications/notifications.component';
export const AdminLayoutRoutes: Routes = [
    { path: 'dashboard',      component: HomeComponent },
    { path: 'user',           component: UserComponent },
    { path: 'courses',        component: CoursesComponent },
    { path: 'students',          component: TablesComponent },
    { path: 'assignmentgroups',     component: TypographyComponent },
    { path: 'assignments',          component: IconsComponent },
    { path: 'submissions',           component: IconsComponent },
    { path: 'transcripts',  component: NotificationsComponent },
    { path: 'timesheets',        component: NotificationsComponent },
    { path: 'reports',        component: NotificationsComponent },
];
