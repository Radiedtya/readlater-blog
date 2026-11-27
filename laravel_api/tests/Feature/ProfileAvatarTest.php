<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ProfileAvatarTest extends TestCase
{
    use RefreshDatabase;

    public function test_authenticated_user_can_upload_and_replace_profile_image(): void
    {
        Storage::fake('public');

        $user = User::factory()->create([
            'profile_image' => 'profile-images/old-avatar.png',
        ]);
        Storage::disk('public')->put($user->profile_image, 'old-avatar');
        Sanctum::actingAs($user);

        $response = $this->withHeaders([
            'Accept' => 'application/json',
        ])->post('/api/user/avatar', [
            'avatar' => UploadedFile::fake()->image('new-avatar.png'),
        ]);

        $response->assertOk();
        $path = $response->json('data.profile_image');
        $this->assertIsString($path);
        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'profile_image' => $path,
        ]);
        Storage::disk('public')->assertExists($path);
        Storage::disk('public')->assertMissing('profile-images/old-avatar.png');
        $response->assertJsonPath(
            'data.profile_image_url',
            route('users.avatar', [
                'user' => $user->id,
                'v' => substr(hash('sha256', $path), 0, 12),
            ]),
        );

        $this->get($response->json('data.profile_image_url'))->assertOk();
    }

    public function test_profile_image_upload_requires_an_image_and_authentication(): void
    {
        $this->postJson('/api/user/avatar', [])->assertUnauthorized();

        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $this->postJson('/api/user/avatar', [
            'avatar' => UploadedFile::fake()->create('notes.txt', 10, 'text/plain'),
        ])->assertUnprocessable();
    }
}
