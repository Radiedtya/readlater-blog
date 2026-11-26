<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Topic;
use Illuminate\Http\JsonResponse;

class TopicController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json([
            'data' => Topic::withCount('bookmarks')->orderBy('id')->get(),
        ]);
    }

    public function show(Topic $topic): JsonResponse
    {
        return response()->json([
            'data' => $topic->loadCount('bookmarks'),
        ]);
    }
}