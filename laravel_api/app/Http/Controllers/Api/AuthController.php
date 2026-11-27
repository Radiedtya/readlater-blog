<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Symfony\Component\HttpFoundation\StreamedResponse;

class AuthController extends Controller
{
    public function showAvatar(User $user): StreamedResponse
    {
        abort_unless(
            $user->profile_image
                && Storage::disk('public')->exists($user->profile_image),
            404,
        );

        /** @var \Illuminate\Filesystem\FilesystemAdapter $disk */
        $disk = Storage::disk('public');
        $path = $user->profile_image;

        return response()->stream(
            static function () use ($disk, $path): void {
                $stream = $disk->readStream($path);

                if ($stream !== false) {
                    fpassthru($stream);
                    fclose($stream);
                }
            },
            200,
            [
                'Content-Type' => $disk->mimeType($path),
                'Cache-Control' => 'public, max-age=3600',
            ],
        );
    }

    public function updateAvatar(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'avatar' => ['required', 'image', 'mimes:jpeg,png,webp', 'max:5120'],
        ]);

        $user = $request->user();
        $path = $validated['avatar']->store(
            'profile-images/'.$user->id,
            'public',
        );

        if ($path === false) {
            Log::error('Failed to store profile image.', ['user_id' => $user->id]);

            return response()->json([
                'message' => 'Foto profil gagal disimpan. Coba lagi.',
            ], 500);
        }

        $previousPath = $user->profile_image;
        $user->profile_image = $path;
        if (! $user->save()) {
            Storage::disk('public')->delete($path);

            return response()->json([
                'message' => 'Foto profil gagal disimpan. Coba lagi.',
            ], 500);
        }

        if ($previousPath && ! Storage::disk('public')->delete($previousPath)) {
            Log::warning('Failed to remove replaced profile image.', [
                'user_id' => $user->id,
                'path' => $previousPath,
            ]);
        }

        return response()->json([
            'message' => 'Foto profil berhasil diperbarui.',
            'data' => $user->fresh(),
        ]);
    }

    /**
     * GET /api/user
     * Kembalikan data user yang sedang login.
     */
    public function user(Request $request): JsonResponse
    {
        return response()->json([
            'data' => $request->user(),
        ]);
    }

    /**
     * PUT /api/user
     * Update profil user yang sedang login (nama, email, dan/atau kata sandi).
     */
    public function updateProfile(Request $request): JsonResponse
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
            'email' => 'sometimes|required|email|max:255|unique:users,email,'.$user->id,
            'current_password' => 'required_with:password|string',
            'password' => 'sometimes|required|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        // Verifikasi kata sandi lama kalau user mau ganti password
        if ($request->filled('password')) {
            if (! Hash::check($request->current_password, $user->password)) {
                return response()->json([
                    'message' => 'Kata sandi saat ini salah.',
                    'errors' => [
                        'current_password' => ['Kata sandi saat ini salah.'],
                    ],
                ], 422);
            }
        }

        $data = [];
        if ($request->filled('name')) {
            $data['name'] = $request->name;
        }
        if ($request->filled('email')) {
            $data['email'] = $request->email;
        }
        if ($request->filled('password')) {
            $data['password'] = Hash::make($request->password);
        }

        if (empty($data)) {
            return response()->json([
                'message' => 'Tidak ada perubahan.',
                'data' => $user,
            ]);
        }

        $user->update($data);

        return response()->json([
            'message' => 'Profil diperbarui.',
            'data' => $user->fresh(),
        ]);
    }

    /**
     * POST /api/register
     * Daftarkan user baru & langsung terbitkan token Sanctum.
     */
    public function register(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|email|max:255|unique:users,email',
            'password' => 'required|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Register success',
            'data' => $user,
            'token' => $token,
            'token_type' => 'Bearer',
        ], 201);
    }

    /**
     * POST /api/login
     * Verifikasi kredensial & terbitkan token.
     */
    public function login(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Email atau kata sandi salah.',
            ], 401);
        }

        // Opsional: komentari baris di bawah kalau mau multi-device login
        // $user->tokens()->delete();

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login success',
            'data' => $user,
            'token' => $token,
            'token_type' => 'Bearer',
        ]);
    }

    /**
     * POST /api/logout
     * Cabut token yang sedang dipakai.
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'logout success',
        ]);
    }
}
