import Navbar from "./Navbar";
import Image from "next/image";
import Link from "next/link";
import toast from "react-hot-toast";
import { assets } from "@/public/assets/assets";
import Footer from "./Footer";


const ProductDetails = ({ productdetails }: { productdetails: any }) => {

const offerPrice = productdetails.price + (productdetails.price * 0.7); // Assuming offer price is 17% more than the original price

  return (
    <>
        <Navbar />
      <div className="max-md:p-0 px-6 md:px-16 lg:px-32 pt-14 space-y-10 max-md:mt-4">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-16">
          <div className="px-5 lg:px-16 xl:px-20">
            <div className="rounded-lg overflow-hidden bg-gray-500/10 mb-4">
              <Image
                src={productdetails.image_url_array[0]}
                alt="alt"
                className="w-full h-auto object-cover mix-blend-multiply"
                width={1280}
                height={720}
                loading="eager"
              />
            </div>
          </div>

          <div className="flex flex-col">
            <h1 className="text-3xl font-medium text-gray-800/90 mb-4">
              {productdetails.name}
            </h1>
            <div className="flex items-center gap-2">
              <div className="flex items-center gap-0.5">
                <Image
                  className="h-4 w-4"
                  src={assets.star_icon}
                  alt="star_icon"
                  loading="eager"
                />
                <Image
                  className="h-4 w-4"
                  src={assets.star_icon}
                  alt="star_icon"
                  loading="eager"
                />
                <Image
                  className="h-4 w-4"
                  src={assets.star_icon}
                  alt="star_icon"
                  loading="eager"
                />
                <Image
                  className="h-4 w-4"
                  src={assets.star_icon}
                  alt="star_icon"
                  loading="eager"
                />
                <Image
                  className="h-4 w-4"
                  src={assets.star_dull_icon}
                  alt="star_dull_icon"
                  loading="eager"
                />
              </div>
              <p>(4.5)</p>
            </div>
            <p className="text-gray-600 mt-3">{productdetails.description}</p>
            <p className="text-3xl font-medium mt-6">
              &#8358;
                {productdetails.price.toLocaleString("en-NG", {
                    minimumFractionDigits: 2,
                })}
              <span className="text-base font-normal text-gray-800/60 line-through ml-2">
                &#8358;
                {offerPrice.toLocaleString("en-NG", {
                    minimumFractionDigits: 2,
                })}
              </span>
            </p>
            <hr className="bg-gray-600 my-6" />
            <div className="overflow-x-auto">
              <table className="table-auto border-collapse w-full max-w-72">
                <tbody>
                  <tr>
                    <td className="text-gray-600 font-medium">Brand</td>
                    <td className="text-gray-800/50 ">{productdetails.brand}</td>
                  </tr>
                  {productdetails?.colors && (
                    <tr>
                      <td className="text-gray-600 font-medium">Colors</td>
                      <td className="text-gray-800/50 ">
                        {productdetails.colors.map((each: any) => `${each} `)}
                      </td>
                    </tr>
                  )}
                  <tr>
                    <td className="text-gray-600 font-medium">Category</td>
                    <td className="text-gray-800/50">
                      {productdetails.category.name}
                    </td>
                  </tr>
                </tbody>
              </table>
              {productdetails.product_comment && (
                <div className="mt-4">
                  <p className="text-black">{productdetails.product_comment}</p>
                </div>
              )}

              <div className="mt-2">
                {productdetails.sizes?.map((each: any, index: number) => (
                  <button
                    className={` text-sm rounded-lg px-2 py-1 mr-1 `}
                    key={index}
                  >
                    {each}
                  </button>
                ))}
              </div>
            </div>

            <div className="flex items-center mt-10 gap-4">
              <button
                // onClick={handleAddToCart}
                className="w-full py-3.5 border border-[#043033] text-gray-800/80 hover:bg-gray-200 transition"
              >
                Add to Cart
              </button>
              <Link
                href={`/buy-now/${productdetails.id}`}
                className="w-full py-3.5 bg-[#043033] text-white text-center hover:bg-black transition"
              >
                Buy now
              </Link>
            </div>
          </div>
        </div>
      </div>
      {/* extra imges */}
      {productdetails.image_url_array.length > 1 &&
        productdetails.image_url_array.length > 0 && (
          <div className="w-full flex justify-center mt-8 ">
            <div className="flex flex-col md:flex-row md:flex-wrap gap-4 w-full max-w-250">
              {productdetails.image_url_array.map((eachImage: any, index: number) => (
                <div
                  key={index}
                  className="w-full md:w-[calc(33.333%-1rem)] shrink-0 bg-gray-100 rounded-lg overflow-hidden"
                >
                  <Image
                    src={eachImage}
                    alt={`Product extra image ${index}`}
                    className="object-cover w-full h-auto"
                    width={400}
                    height={400}
                    loading="eager"
                  />
                </div>
              ))}
            </div>
          </div>
        )}

       <p className="mt-[5vh]"></p>
        <Footer/>
    </>
  )
}

export default ProductDetails;
