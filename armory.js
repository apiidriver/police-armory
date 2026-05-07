// Defiant Armory: Namespaced Module (v3.0)
window.Armory = {
    Render: function(data) {
        const itemsContainer = document.getElementById('items-container');
        if (!itemsContainer) return;
        itemsContainer.innerHTML = '';
        
        // Cart is persistent in Defiant.State
        this.UpdateCartUI();

        if (data.itemsByGrade) {
            for (let grade = 0; grade <= data.maxGrade; grade++) {
                if (data.itemsByGrade[grade] && data.itemsByGrade[grade].length > 0) {
                    const header = $(`
                        <div class="grade-header">
                            <div class="header-content">
                                <span class="collapse-icon">▼</span>
                                <span>RANK ${grade} ASSETS</span>
                            </div>
                        </div>
                    `);
                    const itemsList = $(`<div class="grade-items" style="display: block;"></div>`);
                    $(itemsContainer).append(header).append(itemsList);

                    header.on('click', () => {
                        itemsList.slideToggle(300);
                        const icon = header.find('.collapse-icon');
                        icon.text(icon.text() === '▼' ? '►' : '▼');
                    });

                    data.itemsByGrade[grade].forEach(item => {
                        const el = $(`
                            <div class="armory-item">
                                <div class="item-image" style="background-image: url('nui://ox_inventory/web/images/${window.Defiant.Utils.Sanitize(item.name)}.png');"></div>
                                <div class="item-details">
                                    <div class="item-name">${window.Defiant.Utils.Sanitize(item.label)}</div>
                                    <div class="item-description">${window.Defiant.Utils.Sanitize(item.description) || 'Department Issued'}</div>
                                </div>
                                <div class="item-price">$${Number(item.price)}</div>
                                <div class="item-controls">
                                    <input type="number" class="item-quantity" value="1" min="1">
                                    <button class="add-to-cart-btn buy-button" 
                                            data-item="${window.Defiant.Utils.Sanitize(item.name)}" 
                                            data-label="${window.Defiant.Utils.Sanitize(item.label)}" 
                                            data-price="${Number(item.price)}">ADD</button>
                                </div>
                            </div>
                        `);
                        itemsList.append(el);
                    });
                }
            }
        }
    },

    UpdateCartUI: function() {
        const container = document.getElementById('cart-items');
        if (!container) return;
        container.innerHTML = '';
        let total = 0;
        let count = 0;

        window.Defiant.State.cart.forEach((item, index) => {
            total += item.price * item.amount;
            count += item.amount;
            $(container).append(`
                <div class="cart-item">
                    <div class="cart-item-info">
                        <div class="cart-item-name">${window.Defiant.Utils.Sanitize(item.label)}</div>
                        <div class="cart-item-price">$${Number(item.price * item.amount)}</div>
                    </div>
                    <div class="cart-item-quantity">x${Number(item.amount)}</div>
                    <div class="cart-item-remove">
                        <button class="remove-from-cart-btn remove-button" data-index="${index}">X</button>
                    </div>
                </div>
            `);
        });

        if (window.Defiant.State.cart.length === 0) {
            container.innerHTML = '<div class="empty-cart">Your cart is empty</div>';
        }
        
        document.getElementById('cart-count').textContent = `${count} items`;
        document.getElementById('total-amount').textContent = total;
    }
};

// Event Delegation for Armory Actions
$(document).on('click', '.add-to-cart-btn', function() {
    const name = $(this).data('item');
    const label = $(this).data('label');
    const price = parseInt($(this).data('price'));
    const qtyInput = $(this).siblings('.item-quantity');
    const qty = parseInt(qtyInput.val()) || 1;

    const existing = window.Defiant.State.cart.find(i => i.name === name);
    if (existing) {
        existing.amount += qty;
    } else {
        window.Defiant.State.cart.push({ name, label, price, amount: qty });
    }
    window.Armory.UpdateCartUI();
});

$(document).on('click', '.remove-from-cart-btn', function() {
    const index = $(this).data('index');
    window.Defiant.State.cart.splice(index, 1);
    window.Armory.UpdateCartUI();
});

$(document).on('click', '#checkout-cash', function() {
    if (window.Defiant.State.cart.length === 0) return;
    $.post(`https://${GetParentResourceName()}/checkout`, JSON.stringify({ 
        items: window.Defiant.State.cart,
        paymentType: 'cash'
    }));
    window.Defiant.State.cart = [];
    window.Defiant.Utils.hideAll();
});

$(document).on('click', '#checkout-bank', function() {
    if (window.Defiant.State.cart.length === 0) return;
    $.post(`https://${GetParentResourceName()}/checkout`, JSON.stringify({ 
        items: window.Defiant.State.cart,
        paymentType: 'bank'
    }));
    window.Defiant.State.cart = [];
    window.Defiant.Utils.hideAll();
});
