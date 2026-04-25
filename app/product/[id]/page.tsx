import ProductDetails from "@/Component/ProductDetails";
import { fetchProductById } from "@/lib/Actions/product.action";


const productDetails = async ({ params }: { params: Promise<{ id: string }> }) => {

    const { id } = await params;

    const product = await fetchProductById(id);
    // console.log(product);
  return (
    <div>
     <ProductDetails productdetails={product} />
    </div>
  )
}

export default productDetails;
