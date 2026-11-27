<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
// use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

#[Fillable(['name', 'email', 'password', 'profile_image'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable
{
    protected $appends = ['profile_image_url'];

    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    public function bookmarks(): HasMany
    {
        return $this->hasMany(Bookmark::class);
    }

    public function getProfileImageUrlAttribute(): ?string
    {
        return $this->profile_image
            ? route('users.avatar', [
                'user' => $this->getKey(),
                'v' => substr(hash('sha256', $this->profile_image), 0, 12),
            ])
            : null;
    }

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }
}
