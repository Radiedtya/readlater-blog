<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('bookmarks', function (Blueprint $table) {
            $table->string('source_id')->nullable()->after('key_points');
            // Satu user tidak bisa simpan artikel yang sama dua kali.
            // NULL source_id (bookmark manual) tetap boleh multiple.
            $table->unique(['user_id', 'source_id']);
        });
    }

    public function down(): void
    {
        Schema::table('bookmarks', function (Blueprint $table) {
            $table->dropUnique(['user_id', 'source_id']);
            $table->dropColumn('source_id');
        });
    }
};