<?php

use App\Models\User;
use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('App.Models.User.{id}', function ($user, $id) {
    return (int) $user->id === (int) $id;
});

Broadcast::channel('admin.reports', fn (User $user): bool => $user->isAdmin() && $user->isActive());

Broadcast::channel('admin.tracking', fn (User $user): bool => $user->isAdmin() && $user->isActive());
