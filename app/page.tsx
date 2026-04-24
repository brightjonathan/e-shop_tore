import HeaderSlider from "@/Component/HeaderSlider";
import HomeProduct from "@/Component/HomeProduct";
import Navbar from "@/Component/Navbar";
import { fetchProducts } from "@/lib/Actions/product.action";


//all products
const allProducts = await fetchProducts();

const Home = () => {


  return (
    <div>
      <Navbar/>

      <div>
        <HeaderSlider/>

        <HomeProduct products={allProducts} />
      </div>

    </div>
  )
}

export default Home;

//stop at 1:04:00


