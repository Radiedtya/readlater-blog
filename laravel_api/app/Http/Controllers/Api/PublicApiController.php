<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Client\RequestException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class PublicApiController extends Controller
{
    private const BASE = 'https://dummyjson.com/posts';

    /** GET /api/public/posts?limit=&skip=&q= */
    public function index(Request $request): JsonResponse
    {
        $params = [
            'limit' => (int) $request->input('limit', 20),
            'skip'  => (int) $request->input('skip', 0),
        ];
        if ($request->filled('q')) {
            $params['q'] = $request->string('q')->toString();
        }

        $res = Http::timeout(10)->get(self::BASE, $params)->throw();

        // Detail list page: hanya title & tags
        $data = collect($res->json('posts', []))->map(fn ($p) => [
            'id'    => $p['id'],
            'title' => $p['title'],
            'tags'  => $p['tags'] ?? [],
        ]);

        return response()->json([
            'total' => $res->json('total', 0),
            'skip'  => $res->json('skip', 0),
            'limit' => $res->json('limit', 0),
            'data'  => $data,
        ]);
    }

    /** GET /api/public/posts/{id} */
    public function show(int $id): JsonResponse
    {
        try {
            $res = Http::timeout(10)->get(self::BASE . "/{$id}")->throw();
        } catch (RequestException $e) {
            return response()->json(['message' => 'Post not found'], 404);
        }

        $p = $res->json();

        // Detail page: body, views, reactions (likes)
        return response()->json([
            'data' => [
                'id'        => $p['id'],
                'title'     => $p['title'],
                'body'      => $p['body'],
                'tags'      => $p['tags'] ?? [],
                'views'     => $p['views'] ?? 0,
                'reactions' => [
                    'likes'    => $p['reactions']['likes'] ?? 0,
                    'dislikes' => $p['reactions']['dislikes'] ?? 0,
                ],
            ],
        ]);
    }
}