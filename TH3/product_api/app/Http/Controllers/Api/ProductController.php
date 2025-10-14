<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    // 🟢 Lấy danh sách tất cả sản phẩm
    public function index()
    {
        return response()->json(Product::all(), 200);
    }

    // 🟢 Tạo mới sản phẩm
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255|unique:products,name',
            'description' => 'nullable|string|max:500',
            'price' => 'required|numeric|min:0',
        ]);

        $product = Product::create($validated);

        return response()->json([
            'message' => 'Tạo sản phẩm thành công!',
            'data' => $product
        ], 201);
    }

    // 🟢 Lấy thông tin 1 sản phẩm cụ thể
    public function show(Product $product)
    {
        return response()->json($product, 200);
    }

    // 🟢 Cập nhật thông tin sản phẩm
    public function update(Request $request, Product $product)
    {
        $validated = $request->validate([
            'name' => 'sometimes|string|max:255|unique:products,name,' . $product->id,
            'description' => 'nullable|string|max:500',
            'price' => 'sometimes|numeric|min:0',
        ]);

        $product->update($validated);

        return response()->json([
            'message' => 'Cập nhật sản phẩm thành công!',
            'data' => $product
        ], 200);
    }

    // 🟢 Xóa 1 sản phẩm
    public function destroy(Product $product)
    {
        $product->delete();

        return response()->json([
            'message' => 'Xóa sản phẩm thành công!'
        ], 204);
    }
}
