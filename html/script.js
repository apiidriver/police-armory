let armoryOpen = false;
let isAdmin = false;
let cart = [];

window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'open') {
        const container = document.getElementById('armory-container');
        if (container) {
            container.style.display = 'flex'; // Use flex here
            armoryOpen = true;
        }
        
        const itemsContainer = document.getElementById('items-container');
        if (itemsContainer) {
            itemsContainer.innerHTML = '';
            
            // Display items by grade
            if (data.itemsByGrade) {
                for (let grade = 0; grade <= data.maxGrade; grade++) {
                    if (data.itemsByGrade[grade] && data.itemsByGrade[grade].length > 0) {
                        // Create grade header
                        const gradeHeader = document.createElement('div');
                        gradeHeader.className = 'grade-header';
                        gradeHeader.innerHTML = `
                            <div class="header-content">
                                <span class="collapse-icon">▼</span>
                                <span>Rank ${grade} Items</span>
                            </div>
                        `;
                        gradeHeader.setAttribute('data-grade', grade);
                        itemsContainer.appendChild(gradeHeader);
                        
                        // Create a container for this grade's items
                        const gradeItems = document.createElement('div');
                        gradeItems.className = 'grade-items';
                        gradeItems.id = `grade-${grade}-items`;
                        itemsContainer.appendChild(gradeItems);
                        
                        // Create items for this grade
                        data.itemsByGrade[grade].forEach(item => {
                            const itemElement = document.createElement('div');
                            itemElement.className = 'armory-item';
                            
                            itemElement.innerHTML = `
                                <div class="item-image" style="background-image: url('nui://ox_inventory/web/images/${item.name}.png');"></div>
                                <div class="item-details">
                                    <div class="item-name">${item.label}</div>
                                    <div class="item-description">${item.description || ''}</div>
                                </div>
                                <div class="item-price">${item.price}</div>
                                <div class="item-controls">
                                    <input type="number" class="item-quantity" min="1" value="1">
                                    <button class="add-to-cart" data-item="${item.name}" data-label="${item.label}" data-price="${item.price}">Add to Cart</button>
                                </div>
                            `;
                            
                            document.getElementById(`grade-${grade}-items`).appendChild(itemElement);
                        });
                    }
                }
                
                // Add event listeners to collapsible headers
                document.querySelectorAll('.grade-header').forEach(header => {
                    header.addEventListener('click', function() {
                        const grade = this.getAttribute('data-grade');
                        const itemsContainer = document.getElementById(`grade-${grade}-items`);
                        const icon = this.querySelector('.collapse-icon');
                        
                        if (itemsContainer.style.display === 'none') {
                            itemsContainer.style.display = 'block';
                            icon.textContent = '▼';
                        } else {
                            itemsContainer.style.display = 'none';
                            icon.textContent = '►';
                        }
                    });
                });
                
                // Add event listeners to add-to-cart buttons
                document.querySelectorAll('.add-to-cart').forEach(button => {
                    button.addEventListener('click', function() {
                        const item = this.getAttribute('data-item');
                        const label = this.getAttribute('data-label');
                        const price = parseInt(this.getAttribute('data-price'));
                        const quantity = parseInt(this.parentElement.querySelector('.item-quantity').value) || 1;
                        
                        addToCart(item, label, price, quantity);
                    });
                });
            }
        }
    } else if (data.action === 'close') {
        const container = document.getElementById('armory-container');
        if (container) {
            container.style.display = 'none';
            armoryOpen = false;
        }
    }
});

// Fix the close button functionality
document.addEventListener('DOMContentLoaded', function() {
    const closeButton = document.getElementById('close-button');
    if (closeButton) {
        closeButton.addEventListener('click', function() {
            fetch(`https://${GetParentResourceName()}/close`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({})
            });
            
            // Also hide the UI immediately
            const container = document.getElementById('armory-container');
            if (container) {
                container.style.display = 'none';
                armoryOpen = false;
            }
        });
    }
});

// Fix the ESC key functionality
document.addEventListener('keyup', function(event) {
    if (event.key === 'Escape' && armoryOpen) {
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        });
        
        // Also hide the UI immediately
        const container = document.getElementById('armory-container');
        if (container) {
            container.style.display = 'none';
            armoryOpen = false;
        }
    }
});

function updateCartDisplay() {
    const cartItems = document.getElementById('cart-items');
    const cartCount = document.getElementById('cart-count');
    const totalAmount = document.getElementById('total-amount');
    
    if (!cart || cart.length === 0) {
        cartItems.innerHTML = '<div class="empty-cart">Your cart is empty</div>';
        cartCount.textContent = '0 items';
        totalAmount.textContent = '0';
        return;
    }
    
    cartItems.innerHTML = '';
    
    let total = 0;
    let itemCount = 0;
    
    cart.forEach((item, index) => {
        const itemTotal = item.price * item.quantity;
        total += itemTotal;
        itemCount += item.quantity;
        
        const cartItemElement = document.createElement('div');
        cartItemElement.className = 'cart-item';
        
        cartItemElement.innerHTML = `
            <div class="cart-item-info">
                <div class="cart-item-name">${item.label}</div>
                <div class="cart-item-price">${item.price} × ${item.quantity}</div>
            </div>
            <div class="cart-item-remove">
                <button class="remove-button" data-index="${index}">×</button>
            </div>
        `;
        
        cartItems.appendChild(cartItemElement);
    });
    
    // Add event listeners to remove buttons
    document.querySelectorAll('.remove-button').forEach(button => {
        button.addEventListener('click', function() {
            const index = parseInt(this.getAttribute('data-index'));
            removeFromCart(index);
        });
    });
    
    cartCount.textContent = `${itemCount} item${itemCount !== 1 ? 's' : ''}`;
    totalAmount.textContent = total;
}

function addToCart(item, label, price, quantity) {
    // Check if item already exists in cart
    const existingItemIndex = cart.findIndex(cartItem => cartItem.name === item);
    
    if (existingItemIndex !== -1) {
        // Update quantity if item already exists
        cart[existingItemIndex].quantity += quantity;
    } else {
        // Add new item to cart
        cart.push({
            name: item,
            label: label,
            price: price,
            quantity: quantity
        });
    }
    
    updateCartDisplay();
}

function removeFromCart(index) {
    if (index >= 0 && index < cart.length) {
        cart.splice(index, 1);
        updateCartDisplay();
    }
}

function showCheckout() {
    if (cart.length === 0) {
        return;
    }
    
    const checkoutModal = document.getElementById('checkout-modal');
    const checkoutItems = document.getElementById('checkout-items');
    const checkoutAmount = document.getElementById('checkout-amount');
    
    checkoutItems.innerHTML = '';
    
    let total = 0;
    
    cart.forEach((item, index) => {
        const itemTotal = item.price * item.quantity;
        total += itemTotal;
        
        const checkoutItemElement = document.createElement('div');
        checkoutItemElement.className = 'checkout-item';
        
        checkoutItemElement.innerHTML = `
            <div class="checkout-item-name">${item.label} × ${item.quantity}</div>
            <div class="checkout-item-price">${itemTotal}</div>
            <div class="checkout-item-remove">
                <button class="remove-button" data-index="${index}">Remove</button>
            </div>
        `;
        
        checkoutItems.appendChild(checkoutItemElement);
    });
    
    // Add event listeners to remove buttons in checkout
    document.querySelectorAll('.checkout-item-remove .remove-button').forEach(button => {
        button.addEventListener('click', function() {
            const index = parseInt(this.getAttribute('data-index'));
            removeFromCart(index);
            showCheckout(); // Refresh checkout display
        });
    });
    
    checkoutAmount.textContent = total;
    checkoutModal.style.display = 'flex';
}

// Payment functions
function processPayment(paymentType) {
    if (cart.length === 0) return;
    
    const items = cart.map(item => ({
        name: item.name,
        price: item.price,
        quantity: item.quantity
    }));
    
    fetch(`https://${GetParentResourceName()}/checkout`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            items: items,
            paymentType: paymentType
        })
    }).then(() => {
        // Clear cart after successful purchase
        cart = [];
        updateCartDisplay();
        
        // Close checkout modal
        document.getElementById('checkout-modal').style.display = 'none';
    });
}

// Replace the payment buttons event listeners with a single checkout button
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('checkout-button').addEventListener('click', function() {
        showCheckout();
    });

    // Keep the checkout modal payment options as they are
    document.getElementById('checkout-cash').addEventListener('click', function() {
        processPayment('cash');
    });

    document.getElementById('checkout-bank').addEventListener('click', function() {
        processPayment('bank');
    });

    // Close checkout modal
    document.querySelector('#checkout-modal .modal-close').addEventListener('click', function() {
        document.getElementById('checkout-modal').style.display = 'none';
    });
});

// Admin modal functionality
document.addEventListener('DOMContentLoaded', function() {
    if (document.querySelector('.modal-close')) {
        document.querySelector('.modal-close').addEventListener('click', function() {
            if (document.getElementById('admin-modal')) {
                document.getElementById('admin-modal').style.display = 'none';
            }
        });
    }

    if (document.getElementById('save-item')) {
        document.getElementById('save-item').addEventListener('click', function() {
            const itemName = document.getElementById('item-name').value;
            const itemLabel = document.getElementById('item-label').value;
            const itemDescription = document.getElementById('item-description').value;
            const itemPrice = parseInt(document.getElementById('item-price').value);
            const itemRank = parseInt(document.getElementById('item-rank').value);
            
            if (!itemName || !itemLabel || !itemPrice) {
                // Simple validation
                alert('Please fill in all required fields');
                return;
            }
            
            fetch(`https://${GetParentResourceName()}/addItem`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    name: itemName,
                    label: itemLabel,
                    description: itemDescription,
                    price: itemPrice,
                    rank: itemRank
                })
            }).then(response => {
                document.getElementById('admin-modal').style.display = 'none';
                // Clear form
                document.getElementById('item-name').value = '';
                document.getElementById('item-label').value = '';
                document.getElementById('item-description').value = '';
                document.getElementById('item-price').value = '100';
                document.getElementById('item-rank').value = '0';
            });
        });
    }
});

document.addEventListener('keyup', function(event) {
    if (event.key === 'Escape') {
        if (document.getElementById('checkout-modal').style.display === 'flex') {
            document.getElementById('checkout-modal').style.display = 'none';
        } else if (document.getElementById('admin-modal') && document.getElementById('admin-modal').style.display === 'flex') {
            document.getElementById('admin-modal').style.display = 'none';
        } else if (armoryOpen) {
            fetch(`https://${GetParentResourceName()}/close`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({})
            });
            
            // Also hide the UI immediately
            document.getElementById('armory-container').style.display = 'none';
            armoryOpen = false;
        }
    }
});

// Initialize cart display when page loads
document.addEventListener('DOMContentLoaded', function() {
    updateCartDisplay();
});    // Add event listeners to remove buttons in