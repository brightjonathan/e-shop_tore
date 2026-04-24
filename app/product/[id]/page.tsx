

const productDetails = async ({ params }: { params: Promise<{ id: string }> }) => {

    const { id } = await params;
  return (
    <div>
      <h2>{id}</h2>
    </div>
  )
}

export default productDetails;
