import { Routes } from '@angular/router';

import { HomeComponent } from '../../home/home.component';
import { UserComponent } from '../../user/user.component';
import { CoursesComponent } from '../../courses/courses.component';
import { TablesComponent } from '../../tables/tables.component';
import { TypographyComponent } from '../../typography/typography.component';
import { IconsComponent } from '../../icons/icons.component';
import { MapsComponent } from '../../maps/maps.component';
import { NotificationsComponent } from '../../notifications/notifications.component';
import { UpgradeComponent } from '../../upgrade/upgrade.component';

export const AdminLayoutRoutes: Routes = [
    { path: 'dashboard',      component: HomeComponent },
    { path: 'user',           component: UserComponent },
    { path: 'courses',        component: CoursesComponent },
    { path: 'students',          component: TablesComponent },
    { path: 'assignmentgroups',     component: TypographyComponent },
    { path: 'assignments',          component: IconsComponent },
    { path: 'assignmentsubmissions',           component: MapsComponent },
    { path: 'transcripts',  component: NotificationsComponent },
    { path: 'timesheets',        component: UpgradeComponent },
    { path: 'reports',        component: UpgradeComponent },
];
