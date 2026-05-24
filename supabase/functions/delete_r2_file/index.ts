import { S3Client, DeleteObjectCommand } from "npm:@aws-sdk/client-s3";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT, DELETE',
};

Deno.serve(async (req) => {
  // 1. Xử lý CORS Preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // 2. Nhận tên file cần xoá từ Flutter gửi lên
    const { fileName } = await req.json();

    if (!fileName) {
      return new Response(
        JSON.stringify({ error: 'Thiếu tham số fileName' }), 
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // 3. Khởi tạo kết nối R2 (dùng lại các biến môi trường đã có sẵn)
    const s3Client = new S3Client({
      region: "auto",
      endpoint: `https://${Deno.env.get("R2_ACCOUNT_ID")}.r2.cloudflarestorage.com`,
      credentials: {
        accessKeyId: Deno.env.get("R2_ACCESS_KEY_ID")!,
        secretAccessKey: Deno.env.get("R2_SECRET_ACCESS_KEY")!,
      },
    });

    const bucketName = Deno.env.get("R2_BUCKET_NAME")!;

    // 4. Ra lệnh xoá file (Key chính là đường dẫn file trong bucket, VD: "invitations/12345_abc.png")
    const command = new DeleteObjectCommand({
      Bucket: bucketName,
      Key: fileName,
    });

    await s3Client.send(command);

    return new Response(
      JSON.stringify({ message: 'Xoá file thành công', deletedFile: fileName }), 
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (error: any) {
    console.error("Lỗi khi xoá file:", error);
    return new Response(
      JSON.stringify({ error: error.message || 'Lỗi server không xác định' }), 
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});