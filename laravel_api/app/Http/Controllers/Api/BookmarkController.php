<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Bookmark;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BookmarkController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = $request->user()->bookmarks()->with('topic')->latest();

        if ($request->filled('topic_id')) {
            $query->where('topic_id', $request->integer('topic_id'));
        }
        if ($request->filled('q')) {
            $q = $request->string('q');
            $query->where(fn ($w) => $w->where('title', 'like', "%{$q}%")
                                      ->orWhere('summary', 'like', "%{$q}%"));
        }

        return response()->json(['data' => $query->get()]);
    }

    /** GET /api/bookmarks/check?source_id=X */
    public function check(Request $request): JsonResponse
    {
        $request->validate([
            'source_id' => ['required', 'string'],
        ]);

        $bookmark = $request->user()->bookmarks()
            ->where('source_id', $request->source_id)
            ->first();

        return response()->json([
            'saved'       => (bool) $bookmark,
            'bookmark_id' => $bookmark?->id,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'topic_id'     => ['required', 'exists:topics,id'],
            'title'        => ['required', 'string', 'max:255'],
            'summary'      => ['required', 'string'],
            'key_points'   => ['required', 'array', 'min:1'],
            'key_points.*' => ['string'],
            'source_id'    => ['sometimes', 'nullable', 'string', 'max:255'],
        ]);

        // Cegah duplikat: kalau user sudah simpan source ini, kembalikan existing
        if (! empty($data['source_id'])) {
            $existing = $request->user()->bookmarks()
                ->where('source_id', $data['source_id'])
                ->first();

            if ($existing) {
                return response()->json([
                    'message'        => 'Bookmark sudah ada',
                    'data'           => $existing->load('topic'),
                    'already_exists' => true,
                ], 200);
            }
        }

        $bookmark = $request->user()->bookmarks()->create($data);

        return response()->json([
            'message'        => 'Bookmark created',
            'data'           => $bookmark->load('topic'),
            'already_exists' => false,
        ], 201);
    }

    public function show(Request $request, Bookmark $bookmark): JsonResponse
    {
        $this->authorizeOwner($request, $bookmark);

        return response()->json(['data' => $bookmark->load('topic')]);
    }

    public function update(Request $request, Bookmark $bookmark): JsonResponse
    {
        $this->authorizeOwner($request, $bookmark);

        $data = $request->validate([
            'topic_id'     => ['sometimes', 'exists:topics,id'],
            'title'        => ['sometimes', 'string', 'max:255'],
            'summary'      => ['sometimes', 'string'],
            'key_points'   => ['sometimes', 'array', 'min:1'],
            'key_points.*' => ['string'],
        ]);

        $bookmark->update($data);

        return response()->json([
            'message' => 'Bookmark updated',
            'data'    => $bookmark->fresh('topic'),
        ]);
    }

    public function destroy(Request $request, Bookmark $bookmark): JsonResponse
    {
        $this->authorizeOwner($request, $bookmark);
        $bookmark->delete();

        return response()->json(['message' => 'Bookmark deleted']);
    }

    private function authorizeOwner(Request $request, Bookmark $bookmark): void
    {
        abort_if($bookmark->user_id !== $request->user()->id, 403, 'Forbidden');
    }
}