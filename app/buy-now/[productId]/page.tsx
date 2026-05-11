import React from "react";
import { fetchProductById } from "@/lib/Actions/product.action";
import BuyNowPage from "@/Component/BuyNowPage";

const page = async ({
  params,
}: {
  params: Promise<{ productId: string }>;
}) => {

  const { productId } = await params;

  console.log(productId);

  const product = await fetchProductById(productId);

  if (!product) {
    return <div>Product not found</div>;
  }

  return (
    <div>
        <BuyNowPage product={product}/>
      {/* <h1>{product.name}</h1> */}
    </div>
  );
};

export default page;