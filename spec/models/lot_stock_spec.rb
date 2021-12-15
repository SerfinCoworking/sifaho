require 'rails_helper'

RSpec.describe LotStock, type: :model do
  it 'does not create' do
    lot_stock = LotStock.new
    expect(lot_stock.save).to be false
  end

  context 'create factories' do
    before(:each) do
      product = create(:unidad_product)
      lot = create(:province_lot_without_product, product: product)
      stock = create(:it_stock_without_product, product: product)
      @lot_stock = LotStock.new
      @lot_stock.lot = lot
      @lot_stock.stock = stock
    end

    it 'does create' do
      expect(@lot_stock.save!).to be true
    end

    # attribute
    it 'default quantity' do
      expect(@lot_stock.quantity).to eq(0)
    end

    it 'set quantity' do
      @lot_stock.quantity = 100
      expect(@lot_stock.quantity).to eq(100)
    end

    it 'default archived_quantity' do
      expect(@lot_stock.archived_quantity).to eq(0)
    end

    it 'set archived_quantity' do
      @lot_stock.archived_quantity = 5
      expect(@lot_stock.archived_quantity).to eq(5)
    end

    it 'default reserved_quantity' do
      expect(@lot_stock.reserved_quantity).to eq(0)
    end

    it 'set reserved_quantity' do
      @lot_stock.reserved_quantity = 16
      expect(@lot_stock.reserved_quantity).to eq(16)
    end

    # method
    it 'increments quantity' do
      expect(@lot_stock.quantity).to eq(0)
      @lot_stock.increment(15)
      expect(@lot_stock.quantity).to eq(15)
    end

    it 'decrements quantity' do
      @lot_stock.increment(1500)
      expect(@lot_stock.quantity).to eq(1500)
      @lot_stock.decrement(100)
      expect(@lot_stock.quantity).to eq(1400)
    end

    context 'with available quantity' do
      before(:each) do
        @lot_stock.increment(2500)
      end

      it 'decrements with negative param' do
        expect { @lot_stock.decrement(-100) }.to raise_error(ArgumentError).with_message('La cantidad a decrementar debe ser mayor a 0.')
        expect(@lot_stock.quantity).to eq(2500)
      end

      it 'decrements with negative param' do
        expect { @lot_stock.decrement(3000) }.to raise_error(ArgumentError).with_message("La cantidad en stock es insuficiente del lote #{@lot_stock.lot_code} producto #{@lot_stock.product_name}.")
        expect(@lot_stock.quantity).to eq(2500)
      end

      it 'increments archived quantity' do
        expect(@lot_stock.archived_quantity).to eq(0)
        @lot_stock.increment_archived(150)
        expect(@lot_stock.quantity).to eq(2350)
        expect(@lot_stock.archived_quantity).to eq(150)
      end

      it 'decrements archived quantity' do
        expect(@lot_stock.archived_quantity).to eq(0)
        @lot_stock.increment_archived(150)
        expect(@lot_stock.quantity).to eq(2350)
        expect(@lot_stock.archived_quantity).to eq(150)
        @lot_stock.decrement_archived(50)
        expect(@lot_stock.archived_quantity).to eq(100)
        expect(@lot_stock.quantity).to eq(2400)
      end

      it 'reserve quantity' do
        expect(@lot_stock.reserved_quantity).to eq(0)
        @lot_stock.reserve(900)
        expect(@lot_stock.reserved_quantity).to eq(900)
        expect(@lot_stock.quantity).to eq(1600)
      end

      it 'enabled reserved to quantity' do
        expect(@lot_stock.reserved_quantity).to eq(0)
        @lot_stock.reserve(600)
        expect(@lot_stock.reserved_quantity).to eq(600)
        expect(@lot_stock.quantity).to eq(1900)
        @lot_stock.enable_reserved(300)
        expect(@lot_stock.reserved_quantity).to eq(300)
        expect(@lot_stock.quantity).to eq(2200)
      end

      it 'decrement reserved' do
        expect(@lot_stock.reserved_quantity).to eq(0)
        @lot_stock.reserve(200)
        expect(@lot_stock.reserved_quantity).to eq(200)
        expect(@lot_stock.quantity).to eq(2300)
        @lot_stock.decrement_reserved(200)
        expect(@lot_stock.reserved_quantity).to eq(0)
        expect(@lot_stock.quantity).to eq(2300)
      end

      it 'increment archived with negative param' do
        expect(@lot_stock.archived_quantity).to eq(0)
        expect { @lot_stock.increment_archived(-150) }.to raise_error(ArgumentError).with_message('La cantidad a archivar debe ser mayor a 0.')
        expect(@lot_stock.quantity).to eq(2500)
        expect(@lot_stock.archived_quantity).to eq(0)
      end

      it 'decrement archived with negative param' do
        expect(@lot_stock.archived_quantity).to eq(0)
        @lot_stock.increment_archived(150)
        expect(@lot_stock.quantity).to eq(2350)
        expect(@lot_stock.archived_quantity).to eq(150)
        expect { @lot_stock.decrement_archived(-50) }.to raise_error(ArgumentError).with_message('La cantidad a quitar de archivo debe ser mayor a 0.')
        expect(@lot_stock.archived_quantity).to eq(150)
        expect(@lot_stock.quantity).to eq(2350)
      end

      it 'decrement archived with greater param than archived' do
        expect(@lot_stock.archived_quantity).to eq(0)
        @lot_stock.increment_archived(150)
        expect(@lot_stock.quantity).to eq(2350)
        expect(@lot_stock.archived_quantity).to eq(150)
        expect { @lot_stock.decrement_archived(200) }.to raise_error(ArgumentError).with_message('La cantidad a quitar de archivo debe ser menor o igual a 150.')
        expect(@lot_stock.archived_quantity).to eq(150)
        expect(@lot_stock.quantity).to eq(2350)
      end

      it 'reserve with negative param' do
        expect(@lot_stock.reserved_quantity).to eq(0)
        expect { @lot_stock.reserve(-900) }.to raise_error(ArgumentError).with_message('La cantidad a reservar debe ser mayor a 0.')
        expect(@lot_stock.reserved_quantity).to eq(0)
        expect(@lot_stock.quantity).to eq(2500)
      end

      it 'enable reserve with negative param' do
        expect(@lot_stock.reserved_quantity).to eq(0)
        @lot_stock.reserve(600)
        expect(@lot_stock.reserved_quantity).to eq(600)
        expect(@lot_stock.quantity).to eq(1900)
        expect { @lot_stock.enable_reserved(-300) }.to raise_error(ArgumentError).with_message('La cantidad a devolver de la reserva debe ser nayor a 0.')
        expect(@lot_stock.reserved_quantity).to eq(600)
        expect(@lot_stock.quantity).to eq(1900)
      end

      it 'enable reserve with greater param than reseved' do
        expect(@lot_stock.reserved_quantity).to eq(0)
        @lot_stock.reserve(600)
        expect(@lot_stock.reserved_quantity).to eq(600)
        expect(@lot_stock.quantity).to eq(1900)
        expect { @lot_stock.enable_reserved(700) }.to raise_error(ArgumentError).with_message('La cantidad a devolver de la reserva debe ser menor o igual a 600.')
        expect(@lot_stock.reserved_quantity).to eq(600)
        expect(@lot_stock.quantity).to eq(1900)
      end

      it 'decrement reserve with negative param' do
        expect(@lot_stock.reserved_quantity).to eq(0)
        @lot_stock.reserve(200)
        expect(@lot_stock.reserved_quantity).to eq(200)
        expect(@lot_stock.quantity).to eq(2300)
        expect { @lot_stock.decrement_reserved(-200) }.to raise_error(ArgumentError).with_message('La cantidad a enviar debe ser mayor a 0.')
        expect(@lot_stock.reserved_quantity).to eq(200)
        expect(@lot_stock.quantity).to eq(2300)
      end

      it 'decrement reserve with greater param than reserved' do
        expect(@lot_stock.reserved_quantity).to eq(0)
        @lot_stock.reserve(200)
        expect(@lot_stock.reserved_quantity).to eq(200)
        expect(@lot_stock.quantity).to eq(2300)
        expect { @lot_stock.decrement_reserved(400) }.to raise_error(ArgumentError).with_message('La cantidad a enviar debe ser menor o igual a 200.')
        expect(@lot_stock.reserved_quantity).to eq(200)
        expect(@lot_stock.quantity).to eq(2300)
      end
    end

  end
end
