// Sử dụng chuẩn import npm: mới nhất của Supabase Edge Functions
import { S3Client, PutObjectCommand } from "npm:@aws-sdk/client-s3";
import { getSignedUrl } from "npm:@aws-sdk/s3-request-presigner";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT, DELETE',
};

// Sử dụng Deno.serve (chuẩn API mới)
Deno.serve(async (req) => {
  // 1. Bắt buộc xử lý CORS Preflight ngay đầu tiên
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // 2. Parse dữ liệu từ Flutter
    const { fileName, fileType } = await req.json();

    // 3. Khởi tạo kết nối R2
    const s3Client = new S3Client({
      region: "auto",
      endpoint: `https://${Deno.env.get("R2_ACCOUNT_ID")}.r2.cloudflarestorage.com`,
      credentials: {
        accessKeyId: Deno.env.get("R2_ACCESS_KEY_ID")!,
        secretAccessKey: Deno.env.get("R2_SECRET_ACCESS_KEY")!,
      },
    });

    const bucketName = Deno.env.get("R2_BUCKET_NAME")!;
    const fileKey = `invitations/${Date.now()}_${fileName}`;

    const command = new PutObjectCommand({
      Bucket: bucketName,
      Key: fileKey,
      ContentType: fileType,
    });

    // 4. Sinh URL tải lên có hạn 5 phút
    const signedUrl = await getSignedUrl(s3Client, command, { expiresIn: 300 });
    const publicUrl = `${Deno.env.get("R2_PUBLIC_DOMAIN")}/${fileKey}`;

    return new Response(
      JSON.stringify({ signedUrl, publicUrl, fileKey }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    );
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    });
  }
});